//
//  OtherVoiceCell.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/5.
//

import UIKit
import AVFoundation
import Lottie

class OtherVoiceCell: UITableViewCell, MessageCell {
    var player = AVPlayer()
    var timer = Timer()
    var duration = TimeInterval()
    var totalDuration = TimeInterval()
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chatBubble: UIView!
    @IBOutlet weak var animationView: LottieAnimationView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    func setUpUI() {
        chatBubble.layer.cornerRadius = 15
        chatBubble.backgroundColor = UIColor.myGreen
        friendImageView.layer.cornerRadius = 20
        friendImageView.contentMode = .scaleAspectFill
        playButton.tintColor = UIColor.background
        durationLabel.textColor = UIColor.background
        durationLabel.font = UIFont.systemFont(ofSize: 15)
        timeLabel.textColor = UIColor.systemBrown
        timeLabel.font = UIFont.systemFont(ofSize: 13)

        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.currentFrame = VoiceAnimateKeyFrames.prepare.rawValue
    }

    func layoutCell(with message: Message, friendImageURL: String, viewController: ChatRoomViewController, heroId: String) {
        friendImageView.loadImage(friendImageURL, placeHolder: UIImage(named: Constant.chefMan))
        timeLabel.text = Date.getMessageTimeString(from: Date(timeIntervalSince1970: Double(message.time.seconds)))
        duration = message.duration
        totalDuration = message.duration
        durationLabel.text = self.duration.audioDurationString()

        let playerItem = AVPlayerItem(url: URL(string: message.content)!)
        player.replaceCurrentItem(with: playerItem)
    }

    @IBAction func playAndStop(_ sender: UIButton) {
        if player.timeControlStatus == .playing {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
            player.seek(to: .zero)
            timer.invalidate()
            duration = totalDuration
            durationLabel.text = duration.audioDurationString()
            animationView.stop()
            animationView.currentFrame = VoiceAnimateKeyFrames.prepare.rawValue
        } else {
            playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            player.volume = 1
            player.seek(to: .zero)
            player.play()
            animationView.play(
                fromFrame: VoiceAnimateKeyFrames.start.rawValue,
                toFrame: VoiceAnimateKeyFrames.end.rawValue,
                loopMode: .none,
                completion: nil
            )
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
            duration -= 1
        } else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            duration = totalDuration
            timer.invalidate()
            animationView.stop()
            animationView.currentFrame = VoiceAnimateKeyFrames.prepare.rawValue
        }
        durationLabel.text = duration.audioDurationString()
    }
}
