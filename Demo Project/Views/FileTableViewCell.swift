//
//  FileTableViewCell.swift
//  Demo Project
//
//  Created by DHEERAJ BHAVSAR on 10/10/18.
//  Copyright © 2018 Test Organization. All rights reserved.
//

import UIKit
import AVFoundation

class FileTableViewCell: UITableViewCell {
    
    var audioPlayer: AVAudioPlayer!
    var timer = Timer()
    var timeDuration: Double = 0
    var counterTimeDuration: Double = 0
    var timeInterval = 0.1
    var isTimerOn = false
    
    var isPlaying = false

    @IBOutlet weak var fileThumbnail: UIImageView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var file: File?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(with file: File) {
        self.file = file
        self.fileName.text = file.fileName
        self.fileThumbnail.image = UIImage(data: file.fileThumbnail!)
        self.file = file
        if file.fileType == FileTypes.audio {
            playButton.isHidden = false
        } else {
            playButton.isHidden = true
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        let audioSession = AVAudioSession.sharedInstance()
        try!audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
        if !isPlaying {
            if let audioData = file?.fileData {
                do {
                    audioPlayer = try AVAudioPlayer(data: audioData)
                    audioPlayer.play()
                    self.timeDuration = audioPlayer.duration
                    self.counterTimeDuration = audioPlayer.duration
                    fireTimer()
                    playButton.setImage(UIImage(named: "stop-recording.png"), for: .normal)
                    isPlaying = true
                } catch {
                    print("Error: \(error)")
                }
            }
        } else {
            audioPlayer.stop()
            resetTimer()
            playButton.setImage(UIImage(named: "play-recording.png"), for: .normal)
            isPlaying = false
        }
    }
    
    func fireTimer() {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func resetTimer() {
        timer.invalidate()
        isTimerOn = false
        counterTimeDuration = timeDuration
    }
    
    @objc func updateTimer() {
        counterTimeDuration -= timeInterval     //This will decrement(count down)the seconds.
        if counterTimeDuration <= 0 {
            isTimerOn = false
            timer.invalidate()
            audioPlayer.stop()
            isPlaying = false
            playButton.setImage(UIImage(named: "play-recording.png"), for: .normal)
        }
    }
    
}
