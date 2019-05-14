//
//  FileHandler.swift
//  LuaGameDebuger
//
//  Created by 袁超 on 2019/5/14.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class FileHandler {
    static let shared = FileHandler()
    
    private init() {
       
    }
    
    func zip(directory: String) {
        // all.json
        // patch.json
        let allJson = ""
        let rootDir = ""
        
        var removeFilePathArr = [String]()
        
        if let fileInfoArr = [FileInfo].decode(json: allJson) {
            for fileInfo in fileInfoArr {
                let filePath = fileInfo.filePath!
                let file = rootDir + filePath
                if !FileManager.default.fileExists(atPath: file) {
                    removeFilePathArr.append(filePath)
                }
            }
        }
    }
}
