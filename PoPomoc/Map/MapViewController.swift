//
//  MapViewController.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MapKit
import CoreLocation
import RxMKMapView
import AnimatedField

final class MapViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Attributes
    var presenter: MapPresenterProtocol!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Views
    private let containerView = UIView()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.rowHeight = 50
        table.tableFooterView = UIView(frame: .zero)
        table.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.reuseIdentifier)
        return table
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    private let backButton = BackButton()
    private let choosePlacesView = ChoosePlaceView()
    
    private let carPropositionView = CarPropositionView()
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var visualEffectView: UIVisualEffectView!
    
    let cardHeight: CGFloat = 600
    let cardHandleAreaHeight:CGFloat = 350
    
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    var mapDefaultConstraint: Constraint?
    var mapCarPropositionContraint: Constraint?
}

// MARK: - View Lifecycle
extension MapViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureComponents()
        presenter.inputs.viewDidLoadTrigger.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.inputs.viewWillAppearTrigger.accept(())
        // navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.inputs.viewWillDisappearTrigger.accept(())
        // navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Private functions
private extension MapViewController {
    
    func configureComponents() {
        addSubviews()
        addConstraints()
        setupRx()
        containerView.backgroundColor = .white
        mapView.delegate = self
    }
    
    func addSubviews() {
        view.addSubview(containerView)
        containerView.addSubview(mapView)
        mapView.addSubview(backButton)
        containerView.addSubview(tableView)
        containerView.addSubview(choosePlacesView)
        addChild(carPropositionView)
        view.addSubview(carPropositionView.view)
        carPropositionView.view.isHidden = true
        setupCard()
    }
    
    func addConstraints() {
        containerView.snp.makeConstraints {
            $0.bottom.top.leading.trailing.equalToSuperview()
        }
        choosePlacesView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaInsets.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(choosePlacesView.snp.bottom)
            $0.height.equalTo(300)
            $0.trailing.leading.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(64)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.leading.equalToSuperview()
            mapDefaultConstraint = $0.bottom.equalToSuperview().constraint
            mapCarPropositionContraint = $0.bottom.equalToSuperview().offset(-cardHandleAreaHeight+84).constraint
        }
        
        mapDefaultConstraint?.activate()
        mapCarPropositionContraint?.deactivate()
    }
    
    func setupRx() {
        setupInputs()
        setupOutputs()
    }
    func setupInputs() {
        choosePlacesView.destinationPlacemarkRxText
            .compactMap { $0! }
            .filter { $0.count > 2}
            .map { query -> MKLocalSearch in
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = query
                return MKLocalSearch(request: request)
            }
            .flatMapLatest{ [unowned self] search -> Observable<[MKMapItem]> in
                self.mapItems(for: search)
            }
            .filter { $0.count > 0}
            .bind(to: tableView.rx.items(cellIdentifier: PlaceTableViewCell.reuseIdentifier, cellType: PlaceTableViewCell.self)) { index, model, cell in
                cell.label.text = model.placemark.compactAddress
            }.disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(MKMapItem.self)
            .bind(to: presenter.inputs.destinationPlaceSelected)
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll.subscribe(onNext: { [unowned self] _ in self.view.endEditing(true) }).disposed(by: disposeBag)
        
        backButton.rx.tap.bind(to: presenter.inputs.backButtonTapped).disposed(by: disposeBag)
    }
    
    func setupOutputs() {
        presenter.outputs.drawPolylineDriver
            .drive(onNext: { [unowned self] polylines in
                self.mapView.addOverlays(polylines)
            }).disposed(by: disposeBag)
        
        presenter.outputs.mapAuthorizedDriver.drive(onNext: { [unowned self] in
            self.authorizeMapView()
        }).disposed(by: disposeBag)
        
        presenter.outputs.setMapRegion.drive(onNext: { [unowned self] region in
            self.setMapRegion(region: region)
        }).disposed(by: disposeBag)
        
        presenter.outputs.userLocationAddressDriver.drive(onNext: { [unowned self] address in
            self.choosePlacesView.setupUserLocationText(address: address)
        }).disposed(by: disposeBag)
        
        presenter.outputs.endOfRoutePlacemarkDriver.drive(onNext: { [unowned self] placemark in
            self.mapView.addAnnotation(placemark)
        })//.disposed(by: disposeBag) fix crash here
        
        presenter.outputs.companyListDriver.drive(carPropositionView.tableView.rx.items(cellIdentifier: CarPropositionCell.reuseIdentifier, cellType: CarPropositionCell.self)) { index, model, cell in
            cell.nameLabel.text = model.title
            cell.timeLabel.text = String(model.waitingTime) + " min"
            cell.priceLabel.text = model.price.formattedAmount! + " ZŁ" 
            cell.companyLogo.image = model.image
        }.disposed(by: disposeBag)
        
        presenter.outputs.mapState.drive(onNext: { [unowned self] state in
            switch state {
            case .inputAddress:
                self.tableView.isHidden = false
                self.choosePlacesView.isHidden = false
                self.carPropositionView.view.isHidden = true
                self.visualEffectView.isHidden = true
                mapDefaultConstraint?.activate()
                mapCarPropositionContraint?.deactivate()
            case .chooseResult:
                self.tableView.isHidden = true
                self.choosePlacesView.isHidden = true
                self.carPropositionView.view.isHidden = false
                self.visualEffectView.isHidden = false
                mapDefaultConstraint?.deactivate()
                mapCarPropositionContraint?.activate()
                self.view.endEditing(true)
            }
            
        }).disposed(by: disposeBag)
    }
    
    func authorizeMapView() {
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
    }
    
    func setMapRegion(region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
    
    func mapItems(for searchRequest: MKLocalSearch) -> Observable<[MKMapItem]> {
        return Observable.create { observer in
            searchRequest.start(completionHandler: { (response, error) in
                if let error = error {
                    //observer.onError(error)
                } else {
                    let items = response?.mapItems ?? []
                    observer.onNext(items)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {
                searchRequest.cancel()
            }
        }
    }
    
}

extension MapViewController {
    func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        visualEffectView.isHidden = true
        //self.containerView.addSubview(visualEffectView)
        
        //        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        
        
        carPropositionView.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
        carPropositionView.view.clipsToBounds = true
        
        //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPan(recognizer:)))
        
        // carPropositionView.handleArea.addGestureRecognizer(tapGestureRecognizer)
        carPropositionView.handleArea.addGestureRecognizer(panGestureRecognizer)
        
        
    }
    
    @objc
    func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.carPropositionView.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
        
    }
    
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.carPropositionView.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.carPropositionView.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.carPropositionView.view.layer.cornerRadius = 12
                case .collapsed:
                    self.carPropositionView.view.layer.cornerRadius = 0
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
        }
    }
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .init(red: 0, green: 0, blue: 1, alpha: 0.7)
        return renderer
    }
}

//struct Placemark {
//
//    let locationName: String
//    let thoroughfare: String?
//
//    init(item: MKMapItem) {
//
//        var locationString: String = ""
//
//        if let name = item.name {
//            locationString += "\(name)"
//        }
//
//        if let locality = item.placemark.locality, locality != item.name {
//            locationString += ", \(locality)"
//        }
//
//        if let administrativeArea = item.placemark.administrativeArea,
//            administrativeArea != item.placemark.locality {
//            locationString += ", \(administrativeArea)"
//        }
//
//        if let country = item.placemark.country, country != item.name {
//            locationString += ", \(country)"
//        }
//
//        locationName = locationString
//        thoroughfare = item.placemark.thoroughfare
//    }
//}
