//
//  FileInfo.swift
//  LuaGameDebuger
//
//  Created by 袁超 on 2019/5/14.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class FileInfo: Codable {
    var filePath: String?
    var md5: String?
}

extension FileInfo {
    class func decode(json: String) -> Self? {
        let decoder = JSONDecoder()
        if let data = json.data(using: String.Encoding.utf8) {
            return try? decoder.decode(self, from: data);
        }
        return nil
    }
    
    func encode() -> String? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            return String.init(data: data, encoding: String.Encoding.utf8)
        }
        
        return nil;
    }
}

extension Array where Element: FileInfo {
    static func decode(json: String) -> [Element]? {
        let decoder = JSONDecoder()
        if let data = json.data(using: String.Encoding.utf8) {
            return try? decoder.decode([Element].self, from: data);
        }
        return nil
    }
    
    func encode() -> String? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            return String.init(data: data, encoding: String.Encoding.utf8)
        }
        
        return nil;
    }
}
