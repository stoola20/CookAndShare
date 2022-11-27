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
    private var infoWindow = InfoWindowView()
    private var tappedMarker = GMSMarker()
    lazy var searchThisAreaButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("搜尋這個區域", for: .normal)
        button.setTitleColor(.darkBrown, for: .normal)
        button.addTarget(self, action: #selector(searchThisArea), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    lazy var containerView = UIView()
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var marketButton: UIButton!
    @IBOutlet weak var foodBankButton: UIButton!
    @IBOutlet weak var buttonBackground: UIView!
    @IBOutlet weak var backgroundCenter: NSLayoutConstraint!
    @IBOutlet weak var bannerBackground: UIView!
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

        bannerBackground.layer.shadowColor = UIColor.gray.cgColor
        bannerBackground.layer.shadowOpacity = 0.6
        bannerBackground.layer.shadowOffset = CGSize(width: 1, height: 2)
        bannerBackground.layer.shadowRadius = 1
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

            containerView.topAnchor.constraint(equalTo: marketButton.bottomAnchor, constant: 15),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 40),
            containerView.widthAnchor.constraint(equalToConstant: 130)
        ])

        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOpacity = 0.6
        containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        containerView.layer.shadowRadius = 1
        containerView.layer.cornerRadius = 20

        searchThisAreaButton.clipsToBounds = true
        searchThisAreaButton.layer.cornerRadius = 20
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
                    marker.userData = [
                        "name": placeResult.name,
                        "address": placeResult.address
                    ]
                    marker.map = self.mapView
                }
            }
        }
    }

    @objc func changeCategory(_ sender: UIButton) {
        self.mapView.clear()
        infoWindow.removeFromSuperview()
        searchThisAreaButton.isHidden = true
        buttons.forEach { button in
            button.isSelected = false
        }
        keyword = sender == marketButton ? "市場|supermarket" : "食物銀行"
        fetchNearbyPlace(keyword: keyword, location: dynamicLocation)
        sender.isSelected = true
        backgroundCenter.isActive = false
        backgroundCenter = buttonBackground.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
        backgroundCenter.isActive = true

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func searchThisArea() {
        mapView.clear()
        fetchNearbyPlace(keyword: keyword, location: dynamicLocation)
    }

    @objc func navigate() {
        let locationString = "\(tappedMarker.position.latitude),\(tappedMarker.position.longitude)"
        guard let url = URL(string: "comgooglemaps://?daddr=\(locationString)&directionsmode=driving&zoom=14")
        else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        self.dynamicLocation = location
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
        return UIView()
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        infoWindow.removeFromSuperview()
        tappedMarker = marker
        let location = CLLocationCoordinate2D(
            latitude: marker.position.latitude,
            longitude: marker.position.longitude
        )
        guard
            let nibView = Bundle.main.loadNibNamed(String(describing: InfoWindowView.self), owner: self, options: nil),
            let view = nibView[0] as? InfoWindowView,
            let data = marker.userData as? [String: String],
            let name = data["name"],
            let address = data["address"]
        else { fatalError("Could not create info view") }

        infoWindow = view
        infoWindow.layoutView(name: name, address: address)
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.navigateButton.addTarget(self, action: #selector(navigate), for: .touchUpInside)

        self.view.addSubview(infoWindow)
        searchThisAreaButton.isHidden = true
        return false
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if tappedMarker.userData != nil {
            let location = tappedMarker.position
            infoWindow.center = mapView.projection.point(for: location)
        }
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        searchThisAreaButton.isHidden = true
        infoWindow.removeFromSuperview()
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
            geocoder.reverseGeocodeCoordinate(cameraPosition.target) { [weak self] _, error in
                guard
                    let self = self,
                    error == nil
                else { return }

                self.dynamicLocation = CLLocation(
                    latitude: cameraPosition.target.latitude,
                    longitude: cameraPosition.target.longitude
                )
            }
        }
    }
}
