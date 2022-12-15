//
//  MapViewModel.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/12/15.
//

import Foundation
import CoreLocation
import UIKit.UIApplication

class MapViewModel {
    let placeResults = Observable([PlaceResult()])
    private let dataProvider = GoogleMapDataProvider.shared

    func fetchNearbyPlace(keyword: String, location: CLLocation) {
        placeResults.value = []
        let locationString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        dataProvider.fetchNearbySearch(location: locationString, keyword: keyword) { [weak self] listResponse in
            guard let listResponse = listResponse, let self = self else {
                return
            }
            self.placeResults.value = listResponse.results
        }
    }

    func navigateTo(markerLocation: String) {
        guard let url = URL(string: "comgooglemaps://?daddr=\(markerLocation)&directionsmode=driving&zoom=14")
        else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
