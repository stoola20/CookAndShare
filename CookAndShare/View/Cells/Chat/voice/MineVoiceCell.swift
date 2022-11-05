//
//  MineVoiceCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/5.
//

import UIKit
import AVFoundation

class MineVoiceCell: UITableViewCell {
    var player = AVPlayer()
    var timer = Timer()
    var duration = TimeInterval()
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var chatBubble: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatBubble.layer.cornerRadius = 15
    }

    func layoutCell(with message: Message) {
        timeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))

        let playerItem = AVPlayerItem(url: URL(string: message.content)!)

        player.replaceCurrentItem(with: playerItem)
        player.currentItem!.observe(\AVPlayerItem.status) { [weak self] item, _ in
            guard let self = self else { return }
            guard item == self.player.currentItem else { return }
            if item.status == .readyToPlay {
                self.duration = item.duration.seconds
                self.durationLabel.text = self.duration.audioDurationString()
            }
        }
    }

    @IBAction func playAndStop(_ sender: UIButton) {
        if player.timeControlStatus == .playing {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
            player.seek(to: .zero)
        } else {
            playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            player.volume = 1
            player.seek(to: .zero)
            player.play()
            timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(resetPlayingStatus),
                userInfo: nil,
                repeats: true
            )
        }
    }

    @objc func resetPlayingStatus() {
        if player.timeControlStatus == .playing {
            playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            duration -= player.currentTime().seconds
        } else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            duration = player.currentItem!.duration.seconds
            timer.invalidate()
        }
        durationLabel.text = duration.audioDurationString()
    }
}
