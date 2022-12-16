//
//  MapViewModel.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/12/15.
//

import Foundation
import CoreLocation
import GoogleMaps
import UIKit.UIApplication

class MapViewModel: NSObject, CLLocationManagerDelegate {
    let placeResults = Observable([PlaceResult()])
    let authorizationStatus = Observable(CLAuthorizationStatus(rawValue: 0))
    let userLocation = Observable(CLLocation())
    var keyword = "市場|supermarket"
    let geocoder = GMSGeocoder()
    private let dataProvider = GoogleMapDataProvider.shared
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func fetchNearbyPlace(location: CLLocation) {
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

    private func startLocationServices() {
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        self.authorizationStatus.value = locationAuthorizationStatus

        switch locationAuthorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        default:
            break
        }
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus.value = status

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        self.userLocation.value = location
        manager.stopUpdatingLocation()
        fetchNearbyPlace(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
