//
//  MapInterface.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import RxSwift
import RxCocoa
import MapKit

protocol MapInteractorProtocol: AnyObject {
}

protocol MapCoordinatorDelegate: AnyObject {
}

protocol MapPresenterInputsProtocol: AnyObject {
    var viewDidLoadTrigger: PublishRelay<Void> { get }
    var viewWillAppearTrigger: PublishRelay<Void> { get }
    var viewWillDisappearTrigger: PublishRelay<Void> { get }
    var destinationPlaceSelected: PublishRelay<MKMapItem> { get }
}

protocol MapPresenterOutputsProtocol: AnyObject {
  var drawPolylineDriver: Driver<[MKPolyline]> { get }
  var setMapRegion: Driver<MKCoordinateRegion> { get }
  var mapAuthorizedDriver: Driver<Void> { get }
  var userLocationAddressDriver: Driver<String> { get }
}

protocol MapPresenterProtocol: MapPresenterInputsProtocol, MapPresenterOutputsProtocol {
    var inputs: MapPresenterInputsProtocol { get }
    var outputs: MapPresenterOutputsProtocol { get }
}

extension MapPresenterProtocol where Self: MapPresenterInputsProtocol & MapPresenterOutputsProtocol {
    var inputs: MapPresenterInputsProtocol { return self }
    var outputs: MapPresenterOutputsProtocol { return self }
}
