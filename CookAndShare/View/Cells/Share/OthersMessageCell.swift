//
//  OthersMessageCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit
import GoogleMaps

class OthersMessageCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var imageTimeLabel: UILabel!
    @IBOutlet weak var chatBubble: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hideAllView()
    }

    func layoutCell(with message: Message, friendImageURL: String) {
        friendImageView.load(url: URL(string: friendImageURL)!)
        switch message.contentType {
        case "text":
            messageLabel.text = message.content
            messageLabel.isHidden = false
            timeLabel.isHidden = false
            chatBubble.isHidden = false
        case "image":
            largeImageView.load(url: URL(string: message.content)!)
            imageTimeLabel.isHidden = false
            largeImageView.isHidden = false
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
