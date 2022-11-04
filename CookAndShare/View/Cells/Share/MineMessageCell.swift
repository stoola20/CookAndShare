//
//  MineMessageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import GoogleMaps

class MineMessageCell: UITableViewCell {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapTimeLabel: UILabel!
    @IBOutlet weak var chatBubble: UIView!
    @IBOutlet weak var imageTimeLabel: UILabel!
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        hideAllView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hideAllView()
    }
    
    func hideAllView() {
        messageLabel.isHidden = true
        chatBubble.isHidden = true
        timeLabel.isHidden = true
        imageTimeLabel.isHidden = true
        largeImageView.isHidden = true
        mapView.isHidden = true
        mapTimeLabel.isHidden = true
    }

    func layoutCell(with message: Message) {
        switch message.contentType {
        case "text":
            messageLabel.text = message.content
            messageLabel.isHidden = false
            chatBubble.isHidden = false
            timeLabel.isHidden = false
        case "image":
            largeImageView.load(url: URL(string: message.content)!)
            largeImageView.isHidden = false
            imageTimeLabel.isHidden = false
        case "voice":
            messageLabel.isHidden = true
            timeLabel.isHidden = true
            imageTimeLabel.isHidden = true
            largeImageView.isHidden = true
            mapView.isHidden = true
            mapTimeLabel.isHidden = true
        default:
            mapView.isHidden = false
            mapTimeLabel.isHidden = false

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
}
