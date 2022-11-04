//
//  MapViewController.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/2.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    private let dataProvider = GoogleMapDataProvider.shared
    private let locationManager = CLLocationManager()
    private var location = CLLocation()
    private var keyword = "超市|市場"
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var marketButton: UIButton!
    @IBOutlet weak var foodBankButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "地圖"

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        mapView.delegate = self
        marketButton.addTarget(self, action: #selector(changeCategory(_:)), for: .touchUpInside)
        foodBankButton.addTarget(self, action: #selector(changeCategory(_:)), for: .touchUpInside)
    }
    
    func fetchNearbyPlace(keyword: String) {
        let locationString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        dataProvider.fetchNearbySearch(location: locationString, keyword: keyword) { listResponse in
            guard let listResponse = listResponse else {
                return
            }
            listResponse.results.forEach { placeResult in
                DispatchQueue.main.async {
                    let marker = GMSMarker()
                    marker.isTappable = true
                    marker.position = CLLocationCoordinate2D(
                        latitude: placeResult.geometry.location.lat,
                        longitude: placeResult.geometry.location.lng
                    )
                    marker.icon = GMSMarker.markerImage(with: .systemOrange)
                    marker.accessibilityLabel = placeResult.name
                    marker.accessibilityValue = placeResult.address
                    marker.map = self.mapView
                }
            }
        }
    }
    
    @objc func changeCategory(_ sender: UIButton) {
        self.mapView.clear()
        keyword = sender == marketButton ? "超市|市場" : "食物銀行"
        fetchNearbyPlace(keyword: keyword)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        self.location = location
        mapView.animate(toLocation: location.coordinate)
        mapView.animate(toZoom: 13)
        manager.stopUpdatingLocation()
        fetchNearbyPlace(keyword: keyword)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard
            let nibView = Bundle.main.loadNibNamed(String(describing: InfoWindowView.self), owner: self, options: nil),
            let view = nibView[0] as? InfoWindowView,
            let accessibilityLabel = marker.accessibilityLabel,
            let accessibilityValue = marker.accessibilityValue
        else { return UIView() }
        view.layoutView(name: accessibilityLabel, address: accessibilityValue)
        return view
    }
}
