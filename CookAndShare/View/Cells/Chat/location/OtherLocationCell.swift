//
//  OtherLocationCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/5.
//

import UIKit
import GoogleMaps

class OtherLocationCell: UITableViewCell, MessageCell {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapTimeLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        setUpUI()
    }

    func setUpUI() {
        mapView.layer.cornerRadius = 20
        friendImageView.layer.cornerRadius = 20
        friendImageView.contentMode = .scaleAspectFill
        mapTimeLabel.textColor = UIColor.systemBrown
        mapTimeLabel.font = UIFont.systemFont(ofSize: 13)
    }

    func layoutCell(with message: Message, friendImageURL: String, viewController: ChatRoomViewController, heroId: String) {
        friendImageView.loadImage(friendImageURL, placeHolder: UIImage(named: Constant.chefMan))
        mapTimeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
        layoutMapView(with: message)
    }

    private func layoutMapView(with message: Message) {
        mapView.clear()
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
