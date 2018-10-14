//
//  File.swift
//  Demo Project
//
//  Created by DHEERAJ BHAVSAR on 10/10/18.
//  Copyright © 2018 Test Organization. All rights reserved.
//

import UIKit

class File: Codable {
    
    
    
    var fileName: String?
    var fileData: Data?
    var fileType: String?
    var fileExtension: String?
    var fileThumbnail: Data?
    var fileURL: URL?
    
    private enum CodingKeys: String, CodingKey {
        case fileName
        case fileType
//        case fileData             Skips file data in json encoding
//        case fileThumbnail        Skips file thumbnail data json encoding
    }
    
    init(fileName: String, fileData: Data, fileType: String?, fileExtension: String?, fileThumbnail: Data?, fileURL: URL?) {
        self.fileName = fileName
        self.fileData = fileData
        self.fileType = fileType
        self.fileExtension = fileExtension
        self.fileThumbnail = fileThumbnail
        self.fileURL = fileURL
    }
    
}
