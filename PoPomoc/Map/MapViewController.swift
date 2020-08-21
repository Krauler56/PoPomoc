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

final class MapViewController: BaseViewController {
    
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
    
    private let choosePlacesView = ChoosePlaceView()
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
        containerView.addSubview(tableView)
        containerView.addSubview(choosePlacesView)
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
        
        mapView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.leading.bottom.equalToSuperview()
        }
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
                //request.region = self.region
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
    }
    func setupOutputs() {
        presenter.outputs.drawPolylineDriver
            .drive(onNext: { [unowned self] polylines in
                
                //self.mapView.setRegion(destinationModel.region, animated: true)
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
