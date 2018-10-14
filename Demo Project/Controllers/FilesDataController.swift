//
//  FilesDataController.swift
//  Demo Project
//
//  Created by DHEERAJ BHAVSAR on 10/10/18.
//  Copyright © 2018 Test Organization. All rights reserved.
//

import UIKit

class FilesDataController: NSObject {

    var files = [File]()
    
    func addFile(file: File, isSuccess: @escaping (Bool) -> Void) {
        if files.count < FileConstants.filesLimit {
            self.files.append(file)
            isSuccess(true)
        } else {
            isSuccess(false)
        }
    }
    
}
