//
//  BadgeButton.swift
//  Demo Project
//
//  Created by DHEERAJ BHAVSAR on 12/10/18.
//  Copyright © 2018 Test Organization. All rights reserved.
//

import UIKit

class BadgeButton: UIButton {
    
    var badgeNumber: Int = 0
    var badgeheight: CGFloat = 24
    var badgeView = UIView()
    var badgeLabel = UILabel()

//     Only override draw() if you perform custom drawing.
//     An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        drawBadge()
        if self.badgeNumber > 0 {
            badgeView.isHidden = false
        } else {
            badgeView.isHidden = true
        }
    }

    func drawBadge() {
        
        badgeView.backgroundColor = UIColor.red
        badgeView.frame.size.height = badgeheight
        badgeView.cornerRadius = badgeView.frame.size.height / 2
        
        badgeLabel.text = "\(self.badgeNumber)"
        let badgeLabelHeight: CGFloat = badgeView.frame.size.height - 4
        let badgeLabelWidth = badgeLabel.intrinsicContentSize.width
        badgeLabel.textColor = UIColor.white
        
        if badgeLabel.text?.count == 1 {
            badgeView.frame.size.width = badgeView.frame.height
        } else {
            badgeView.frame.size.width = badgeLabel.intrinsicContentSize.width + 8
        }
        
        
        let badgeCenter = CGPoint(x: self.frame.width, y: 0)
        badgeView.center = badgeCenter
        
        
        
        badgeLabel.frame = CGRect(x: badgeView.frame.width / 2 - badgeLabelWidth / 2, y: badgeView.frame.height / 2 - badgeLabelHeight / 2, width: badgeLabelWidth, height: badgeLabelHeight)
        
        badgeView.addSubview(badgeLabel)
        self.addSubview(badgeView)
    }
    
    func increaseBadgeNumber() {
        self.badgeNumber += 1
        if self.badgeView.isHidden {
            self.badgeView.isHidden = false
        }
        self.badgeLabel.text = "\(self.badgeNumber)"
        updateWidthOfBadgeView()
    }
    
    func decreaseBadgeNumber() {
        if self.badgeNumber > 1 {
            self.badgeNumber -= 1
            self.badgeLabel.text = "\(self.badgeNumber)"
            updateWidthOfBadgeView()
        } else {
            self.badgeNumber -= 1
            self.badgeView.isHidden = true
            updateWidthOfBadgeView()
        }
    }
    
    func setBadgeNumber(to badgeNumber: Int) {
        if badgeNumber > 0 {
            self.badgeNumber = badgeNumber
            self.badgeLabel.text = "\(self.badgeNumber)"
        } else if badgeNumber == 0 {
            self.badgeNumber = badgeNumber
            self.badgeLabel.text = "\(self.badgeNumber)"
            self.badgeView.isHidden = true
            updateWidthOfBadgeView()
        }
    }
    
    func updateWidthOfBadgeView() {
        self.badgeView.removeFromSuperview()
        drawBadge()
    }

}
