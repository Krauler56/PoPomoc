//
//  MapPresenter.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import RxSwift
import RxCocoa
import MapKit

final class MapPresenter: NSObject, MapPresenterProtocol {
    
    // MARK: - Inputs
    
    let viewDidLoadTrigger = PublishRelay<Void>()
    let viewWillAppearTrigger = PublishRelay<Void>()
    let viewWillDisappearTrigger = PublishRelay<Void>()
    let destinationPlaceSelected = PublishRelay<MKMapItem>()
    let regionSelected = PublishRelay<MKCoordinateRegion>()
    let backButtonTapped = PublishRelay<Void>()
    
    // MARK: - Outputs
    var drawPolylineDriver: Driver<[MKPolyline]> {
        return drawPolylineRelay.asDriver(onErrorJustReturn: [])
    }
    var setMapRegion: Driver<MKCoordinateRegion> {
        return setRegionRelay.asDriver(onErrorJustReturn: MKCoordinateRegion())
    }
    
    var userLocationAddressDriver: Driver<String> {
        return userLocationAddress.asDriver(onErrorJustReturn: String())
    }
    
    var mapAuthorizedDriver: Driver<Void> {
        return mapAuthorized.asDriver(onErrorJustReturn: ())
    }
    
    var companyListDriver: Driver<[Company]> {
        return companyListRelay.asDriver(onErrorJustReturn: [])
    }
    
    var endOfRoutePlacemarkDriver: Driver<MKPlacemark> {
        return endOfRoutePlacemarkRelay.asDriver(onErrorJustReturn: MKPlacemark())
    }
    
    // MARK: - Attributes
    
    private let interactor: MapInteractorProtocol
    weak var coordinator: MapCoordinatorDelegate?
    
    
    let locationManager = CLLocationManager()
    private var localSearch: MKLocalSearch?
    private var region = MKCoordinateRegion()
    var actualLocation: CLLocationCoordinate2D?
    
    private let setRegionRelay = PublishRelay<MKCoordinateRegion>()
    private let drawPolylineRelay = PublishRelay<[MKPolyline]>()
    private let companyListRelay = PublishRelay<[Company]>()
    private let endOfRoutePlacemarkRelay = PublishRelay<MKPlacemark>()
    private let mapAuthorized = PublishRelay<Void>()
    private let userLocationAddress = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    
    // STATES: - States
    
    var mapState: Driver<MapState> {
        return state.asDriver(onErrorJustReturn: .inputAddress)
    }
    private let state = PublishRelay<MapState>()
    // MARK: - Functions
    
    init(interactor: MapInteractorProtocol) {
        self.interactor = interactor
        super.init()
        inputs.viewDidLoadTrigger.subscribe(onNext: { [weak self] in
            self?.viewDidLoad()
        }).disposed(by: disposeBag)
    }
}

private extension MapPresenter {
    
    func viewDidLoad() {
        checkLocationServices()
        setupRx()
    }
    
    func setupRx() {
        destinationPlaceSelected.subscribe(onNext: { [unowned self] model in
            
            let request = MKDirections.Request()
            request.source = MKMapItem.forCurrentLocation()
            request.destination = model
            let directions = MKDirections(request: request)
            
            directions.calculate { [unowned self] response, error in
                guard let routes = response?.routes else { return }
                let rect = response!.routes[0].polyline.boundingMapRect
                
                var routeRegion = MKCoordinateRegion(rect)
                routeRegion.span.latitudeDelta *= 1.2
                routeRegion.span.longitudeDelta *= 1.2
                let overlays = routes.map { $0.polyline }
                self.endOfRoutePlacemarkRelay.accept(model.placemark)
                self.setRegionRelay.accept(routeRegion)
                self.drawPolylineRelay.accept(overlays)
                self.state.accept(.chooseResult)
            }
        }).disposed(by: disposeBag)
        
        companyListRelay.accept([Company(title: "Company1", image: R.image.sap()!, price: 223, waitingTime: 1),
                                 Company(title: "Company2", image: R.image.illustrator()!, price: 232, waitingTime: 2),
                                 Company(title: "Company3", image: R.image.photoshop()!, price: 387, waitingTime: 3),
                                 Company(title: "Company4", image: R.image.tags()!, price: 432, waitingTime: 4),
                                 Company(title: "Company5", image: R.image.logo()!, price: 753, waitingTime: 5)])
        
        backButtonTapped.subscribe(onNext: { [unowned self] _ in
            self.state.accept(.inputAddress)
        }).disposed(by: disposeBag)
    }
}

extension MapPresenter: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let lastLocation = locations.last else {
            return
        }
        let span = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        region = MKCoordinateRegion(center: lastLocation.coordinate, span: span)
        actualLocation = lastLocation.coordinate
        setRegionRelay.accept(region)
        reverseLocation(location: lastLocation)
        locationManager.stopUpdatingLocation()
    }
    
    func reverseLocation(location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { [unowned self] (placemarks, error) -> Void in
            var string: String = String()
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if let street = placeMark.thoroughfare {
                string += street + " "
            }
            
            if let city = placeMark.subAdministrativeArea {
                string += city
            }
            
            self.userLocationAddress.accept(string)
        })
    }
}

private extension MapPresenter {
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapAuthorized.accept(Void())
        case .denied: // Show alert telling users how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapAuthorized.accept(Void())
        case .restricted: // Show an alert letting them know what’s up
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }}

enum MapState {
    case inputAddress
    case chooseResult
}
