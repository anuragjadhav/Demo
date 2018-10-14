//
//  ViewFileViewController.swift
//  Demo Project
//
//  Created by DHEERAJ BHAVSAR on 12/10/18.
//  Copyright © 2018 Test Organization. All rights reserved.
//

import UIKit
import WebKit

class ViewFileViewController: UIViewController {

    var fileURL: URL?
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openFile()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
    }
    
    @objc func canRotate() -> Void {}
    
    func openFile() {
        if let url = fileURL {
            webView.load(URLRequest(url: url))
        }
    }

}
