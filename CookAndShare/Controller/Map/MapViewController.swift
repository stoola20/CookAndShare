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
    private var dynamicLocation = CLLocation()
    private var keyword = "市場|supermarket"
    private let geocoder = GMSGeocoder()
    private var isFirstCamera = true
    lazy var searchThisAreaButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .background
        button.setTitle("搜尋這個區域", for: .normal)
        button.setTitleColor(.darkBrown, for: .normal)
        button.addTarget(self, action: #selector(searchThisArea), for: .touchUpInside)
        return button
    }()
    lazy var containerView = UIView()
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var marketButton: UIButton!
    @IBOutlet weak var foodBankButton: UIButton!
    @IBOutlet weak var buttonBackground: UIView!
    @IBOutlet weak var backgroundCenter: NSLayoutConstraint!
    @IBOutlet weak var backgroundWidth: NSLayoutConstraint!
    @IBOutlet var buttons: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "地圖"
        let barAppearance = UINavigationBarAppearance()
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.darkBrown as Any,
            .font: UIFont.boldSystemFont(ofSize: 28)
        ]
        barAppearance.titlePositionAdjustment = UIOffset(horizontal: -200, vertical: 0)
        barAppearance.shadowColor = nil
        barAppearance.backgroundColor = .lightOrange
        navigationItem.standardAppearance = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance

        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        mapView.delegate = self

        marketButton.addTarget(self, action: #selector(changeCategory(_:)), for: .touchUpInside)
        foodBankButton.addTarget(self, action: #selector(changeCategory(_:)), for: .touchUpInside)
        setUpUI()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }

        configSearchAreaButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchThisAreaButton.isHidden = true
    }

    func setUpUI() {
        marketButton.isSelected = true
        marketButton.setTitleColor(UIColor.background, for: .selected)
        marketButton.setTitleColor(UIColor.myOrange, for: .normal)
        marketButton.tintColor = .clear
        foodBankButton.setTitleColor(UIColor.background, for: .selected)
        foodBankButton.setTitleColor(UIColor.myOrange, for: .normal)
        foodBankButton.tintColor = .clear
        buttonBackground.layer.cornerRadius = 10
    }

    func configSearchAreaButton() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        searchThisAreaButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(searchThisAreaButton)
        view.insertSubview(containerView, aboveSubview: mapView)

        NSLayoutConstraint.activate([
            searchThisAreaButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchThisAreaButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchThisAreaButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            searchThisAreaButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            containerView.topAnchor.constraint(equalTo: marketButton.bottomAnchor, constant: 10),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 30),
            containerView.widthAnchor.constraint(equalToConstant: 130)
        ])

        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        containerView.layer.shadowRadius = 2
        containerView.layer.cornerRadius = 15

        searchThisAreaButton.clipsToBounds = true
        searchThisAreaButton.layer.cornerRadius = 15
    }

    func fetchNearbyPlace(keyword: String, location: CLLocation) {
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
        buttons.forEach { button in
            button.isSelected = false
        }
        keyword = sender == marketButton ? "市場|supermarket" : "食物銀行"
        fetchNearbyPlace(keyword: keyword, location: location)
        sender.isSelected = true
        backgroundCenter.isActive = false
        backgroundCenter = buttonBackground.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
        backgroundCenter.isActive = true

        backgroundWidth.isActive = false
        backgroundWidth = buttonBackground.widthAnchor.constraint(equalTo: sender.widthAnchor, multiplier: 0.9)
        backgroundWidth.isActive = true

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func searchThisArea() {
        mapView.clear()
        fetchNearbyPlace(keyword: keyword, location: dynamicLocation)
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
        fetchNearbyPlace(keyword: keyword, location: location)
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

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        searchThisAreaButton.isHidden = true
    }

    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        if isFirstCamera {
            searchThisAreaButton.isHidden = true
            isFirstCamera.toggle()
        } else {
            searchThisAreaButton.isHidden = false
            geocoder.reverseGeocodeCoordinate(cameraPosition.target) { [weak self] response, error in
                guard
                    let self = self,
                    error == nil
                else { return }
                
                self.dynamicLocation = CLLocation(latitude: cameraPosition.target.latitude, longitude: cameraPosition.target.longitude)
            }
        }
    }
}
