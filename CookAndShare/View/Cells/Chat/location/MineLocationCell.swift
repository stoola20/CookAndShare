//
//  MineLocationCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/5.
//

import UIKit
import GoogleMaps

class MineLocationCell: UITableViewCell {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.layer.cornerRadius = 20
    }

    func layoutCell(with message: Message) {
        mapTimeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
        let subString = message.content.split(separator: ",")
        guard
            let lat = Double(subString[0]),
            let lng = Double(subString[1])
        else { return }
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        mapView.animate(toLocation: location)
        mapView.animate(toZoom: 13)

        let marker = GMSMarker()
        marker.position = location
        marker.icon = GMSMarker.markerImage(with: .systemOrange)
        marker.map = self.mapView
    }
}
