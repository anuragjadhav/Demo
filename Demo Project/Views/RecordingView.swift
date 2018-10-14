//
//  RecordingView.swift
//  Demo Project
//
//  Created by DHEERAJ BHAVSAR on 11/10/18.
//  Copyright © 2018 Test Organization. All rights reserved.
//

import UIKit

protocol RecordingViewDelegate : class {
    func didTapCancelRecordingButton()
    func didTapAttachRecordingButton()
    func didTapStartRecordingButton()
    func didTapPauseRecordingButton()
    func didTapResumeRecordingButton()
}

class RecordingView: UIView {
    
    weak var delegate: RecordingViewDelegate?
    
    var timer = Timer()
    
    var timeDuration = TimerConstants.timerDuration
    var isTimerOn = false
    
    var isRecording = false
    var isRecordingPaused = false
    
    let shapeLayer = CAShapeLayer()

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var micView: UIView!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RecordingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        makeCircle()
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func makeCircle() {

        let center = self.micView.center

        //Track Layer
        let trackLayer = CAShapeLayer()

        let circularPath = UIBezierPath(arcCenter: center, radius: CircularPathConstants.radius, startAngle: CircularPathConstants.startAngle, endAngle: CircularPathConstants.endAngle, clockwise: CircularPathConstants.isClockWise)

        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = TrackLayerConstants.strokeColor
        trackLayer.lineWidth = TrackLayerConstants.lineWidth
        trackLayer.fillColor = TrackLayerConstants.fillColor
        trackLayer.lineCap = TrackLayerConstants.lineCap

        self.layer.addSublayer(trackLayer)

        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = ShapeLayerConstants.strokeColor
        shapeLayer.lineWidth = ShapeLayerConstants.lineWidth
        shapeLayer.fillColor = ShapeLayerConstants.fillColor
        shapeLayer.lineCap = ShapeLayerConstants.lineCap
        shapeLayer.strokeEnd = ShapeLayerConstants.strokeEnd

        self.layer.addSublayer(shapeLayer)
    }
    
    //MARK: Animation methods
    func addAnimationToShapeLayer() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = ShapeLayerAnimationConstants.toValue
        animation.duration = ShapeLayerAnimationConstants.duration
        animation.fillMode = ShapeLayerAnimationConstants.fillMode
        animation.isRemovedOnCompletion = ShapeLayerAnimationConstants.isRemovedOnCompletion
        shapeLayer.add(animation, forKey: ShapeLayerAnimationConstants.animationKey)
    }
    
    func pauseAnimation(_ theLayer: CALayer?) {
        let mediaTime = CACurrentMediaTime()
        let pausedTime: CFTimeInterval? = theLayer?.convertTime(mediaTime, from: nil)
        theLayer?.speed = 0.0
        theLayer?.timeOffset = pausedTime ?? 0
    }
    
    func removePause(for theLayer: CALayer?) {
        theLayer?.speed = 1.0
        theLayer?.timeOffset = 0.0
        theLayer?.beginTime = 0.0
    }
    
    func resumeAnimation(_ theLayer: CALayer?) {
        let pausedTime: CFTimeInterval? = theLayer?.timeOffset
        removePause(for: theLayer)
        let mediaTime = CACurrentMediaTime()
        let timeSincePause: CFTimeInterval = (theLayer?.convertTime(mediaTime, from: nil) ?? 0) - (pausedTime ?? 0)
        theLayer?.beginTime = timeSincePause
    }
    
    //MARK: Recorder methods
    func startRecorder() {
        addAnimationToShapeLayer()
        isRecording = true
        isRecordingPaused = false
        runTimer()
        recordingButton.setImage(UIImage(named: "pause.png"), for: .normal)
    }
    
    func pauseRecorder() {
        isRecordingPaused = true
        pauseTimer()
        pauseAnimation(shapeLayer)
        recordingButton.setImage(UIImage(named: "play.png"), for: .normal)
    }
    
    func resumeRecorder() {
        isRecordingPaused = false
        resumeTimer()
        resumeAnimation(shapeLayer)
        recordingButton.setImage(UIImage(named: "pause.png"), for: .normal)
    }
    
    func resetRecorder() {
        shapeLayer.removeAnimation(forKey: ShapeLayerAnimationConstants.animationKey)
        isRecording = false
        if isRecordingPaused {
            startRecorder()
            resetRecorder()
            isRecordingPaused = false
        }
        resetTimer()
        recordingButton.setImage(UIImage(named: "microphone.png"), for: .normal)
        if !recordingButton.isEnabled {
            recordingButton.isEnabled = true
        }
    }
    
    //MARK: Timer methods
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: TimerConstants.timeInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isTimerOn = true
    }
    
    func pauseTimer() {
        timer.invalidate()
        isTimerOn = false
    }
    
    func resumeTimer() {
        runTimer()
        isTimerOn = false
    }
    
    func resetTimer() {
        timer.invalidate()
        isTimerOn = false
        timeDuration = TimerConstants.timerDuration
    }
    
    @objc func updateTimer() {
        timeDuration -= TimerConstants.timeInterval     //This will decrement(count down)the seconds.
        if timeDuration <= 0 {
            recordingButton.setImage(UIImage(named: "microphone.png"), for: .normal)
            recordingButton.isEnabled = false
            timer.invalidate()
        }
        var seconds = "\(Int(TimerConstants.timerDuration - timeDuration))"
        var minutes = "\(Int(TimerConstants.timerDuration - timeDuration)/60)"
        if seconds.count == 1 {
            seconds = "0\(seconds)"
        }
        if minutes.count == 1 {
            minutes = "0\(minutes)"
        }
        self.timeLabel.text = "\(minutes):\(seconds)"
    }
    
    @IBAction func recordingButtonTapped(_ sender: UIButton) {
        attachButton.isEnabled = true
        if !isRecording {
            delegate?.didTapStartRecordingButton()
            startRecorder()
        } else {
            if !isRecordingPaused {
                delegate?.didTapPauseRecordingButton()
                pauseRecorder()
            } else {
                delegate?.didTapResumeRecordingButton()
                resumeRecorder()
            }
        }
    }
    
    
    @IBAction func attachButtonTapped(_ sender: UIButton) {
        //Attch file and then dismiss
        delegate?.didTapAttachRecordingButton()
        resetTimer()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        //Dismiss
        delegate?.didTapCancelRecordingButton()
        resetTimer()
    }
    
}
