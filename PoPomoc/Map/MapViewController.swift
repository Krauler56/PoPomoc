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

final class MapViewController: BaseViewController {
    
    // MARK: - Attributes
    var presenter: MapPresenterProtocol!
    
    private let containerView = UIView()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.reuseIdentifier)
        return table
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    private let searchController: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .white
        return searchBar
    }()
    private let disposeBag = DisposeBag()
    
    // MARK: - Views
    
    
    private let locationManager = CLLocationManager()
    //private let request = MKLocalSearch.Request()
    private var localSearch: MKLocalSearch?
    private var region = MKCoordinateRegion()
    private var searchText: String = ""
    private var placemarks = [Placemark]()
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
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.inputs.viewWillDisappearTrigger.accept(())
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Private functions
private extension MapViewController {
    
    func configureComponents() {
        addSubviews()
        addConstraints()
        setupRx()
      checkLocationServices()
        containerView.backgroundColor = .red
        navigationItem.titleView = searchController
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func addSubviews() {
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(mapView)
    }
    
    func addConstraints() {
        containerView.snp.makeConstraints {
            $0.bottom.top.leading.trailing.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(300)
            $0.trailing.leading.equalToSuperview()
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom)
            $0.trailing.leading.bottom.equalToSuperview()
        }
    }
    
    func setupRx() {
        
        searchController.rx.text
            .compactMap { $0! }
            .filter { $0.count > 2}
            .map { query -> MKLocalSearch in
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = query
                request.region = self.region
                return MKLocalSearch(request: request)
            }
            .flatMapLatest{ [unowned self] search -> Observable<[MKMapItem]> in
                self.mapItems(for: search)
            }
            .filter { $0.count > 0}
            .bind(to: tableView.rx.items(cellIdentifier: PlaceTableViewCell.reuseIdentifier, cellType: PlaceTableViewCell.self)) { index, model, cell in
                cell.label.text = model.name
                
            }
        //.subscribe(onNext: { text in print(text) })
    }
    func mapItems(for searchRequest: MKLocalSearch) -> Observable<[MKMapItem]> {
        return Observable.create { observer in
            searchRequest.start(completionHandler: { (response, error) in
                if let error = error {
                    observer.onError(error)
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
    //
    //    func test(text: String) {
    //
    //        localSearch?.cancel()
    //
    //        request.naturalLanguageQuery = searchText
    //        request.region = region
    //        localSearch = MKLocalSearch(request: request)
    //        localSearch?.start { [weak self] searchResponse, laa in
    //
    //            guard let items = searchResponse?.mapItems else {
    //                return
    //            }
    //
    //            self?.placemarks = items.map { Placemark(item: $0) }
    //            print(items)
    //        }
    //    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let lastLocation = locations.last else {
            return
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        region = MKCoordinateRegion(center: lastLocation.coordinate, span: span)
    }
}

struct Placemark {
    
    let locationName: String
    let thoroughfare: String?
    
    init(item: MKMapItem) {
        
        var locationString: String = ""
        
        if let name = item.name {
            locationString += "\(name)"
        }
        
        if let locality = item.placemark.locality, locality != item.name {
            locationString += ", \(locality)"
        }
        
        if let administrativeArea = item.placemark.administrativeArea,
            administrativeArea != item.placemark.locality {
            locationString += ", \(administrativeArea)"
        }
        
        if let country = item.placemark.country, country != item.name {
            locationString += ", \(country)"
        }
        
        locationName = locationString
        thoroughfare = item.placemark.thoroughfare
    }
}
private extension MapViewController {
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .denied: // Show alert telling users how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted: // Show an alert letting them know what’s up
            break
        case .authorizedAlways:
            break
        }
    }}
