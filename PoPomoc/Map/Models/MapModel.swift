//
//  MapModel.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import Foundation
import MapKit

struct SelectedDestinationModel {
    var polylines: [MKPolyline]
    var region: MKCoordinateRegion
}

struct UserLocationModel {
  var selectedMapItem: MKMapItem
  var actualCoordinates: CLLocationCoordinate2D
}
