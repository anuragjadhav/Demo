//
//  Constants.swift
//  Demo Project
//
//  Created by DHEERAJ BHAVSAR on 11/10/18.
//  Copyright © 2018 Test Organization. All rights reserved.
//

import UIKit

struct TimerConstants {
    static let timeInterval: Double = 0.1
    static let timerDuration: Double = 10
}

struct FileConstants {
    static let filesLimit = 5
}

struct RecordingViewFrameConstants {
    static let height: CGFloat = 240
    static let width: CGFloat = 240
}

struct VideoRecordingConstants {
    static let maximumDuration: Double = 60     //1 min maximum
}

struct ImageConstants {
    static let compressionQuality: CGFloat = 0.5
    static let thumbnailCompressionQuality: CGFloat = 0.1
}

struct CircularPathConstants {
    static let radius: CGFloat = 30
    static let startAngle = -CGFloat.pi / 2
    static let endAngle = 2 * CGFloat.pi
    static let isClockWise = true
}

struct TrackLayerConstants {
    static let strokeColor = UIColor.lightGray.cgColor
    static let lineWidth: CGFloat = 3
    static let fillColor = UIColor.clear.cgColor
    static let lineCap = CAShapeLayerLineCap.round
}

struct ShapeLayerConstants {
    static let strokeColor = UIColor.red.cgColor
    static let lineWidth: CGFloat = 5
    static let fillColor = UIColor.clear.cgColor
    static let lineCap = CAShapeLayerLineCap.round
    static let strokeEnd: CGFloat = 0
}

struct ShapeLayerAnimationConstants {
    static let toValue: CGFloat = 1
    static let duration = TimerConstants.timerDuration + 3
    static let fillMode = CAMediaTimingFillMode.forwards
    static let isRemovedOnCompletion = false
    static let animationKey = "strokeEndAnimation"
}

struct FileTypes {
    static var image = "image"
    static var video = "video"
    static var document = "document"
    static var audio = "audio"
}
