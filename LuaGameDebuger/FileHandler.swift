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
    
    var codingDir = "" {
        didSet {
            UserDefaults.standard.set(codingDir, forKey: "codingDir")
        }
    }
    var siteDir = "" {
        didSet {
            
        }
    }
    
    var isPatch = false {
        didSet {
            UserDefaults.standard.set(isPatch, forKey: "isPatch")
        }
    }
    
    var userName = ""
    
    var gameInitInfo = "" {
        didSet {
            UserDefaults.standard.set(gameInitInfo, forKey: "gameInitInfo")
        }
    }
    
    private init() {
        self.codingDir = UserDefaults.standard.string(forKey: "codingDir") ?? ""
        self.siteDir = findSitesDir() ?? ""
        self.isPatch = UserDefaults.standard.bool(forKey: "isPatch")  
        
        let arr = siteDir.split(separator: "/")
        if arr.count == 3 {
            userName = String(arr[1])
        }
    }
    
    func createZip() -> Bool {
        return zip(codingDir)
    }
    
    func createPatchZip(_ allFileJson: String) -> Bool {
        let startTime = CACurrentMediaTime()
        print("startDate = ",startTime)
        let fileInfoArr = [FileInfo].decode(json: allFileJson) ?? []
        
        var removeFilePathArr = [String]()
        var reserveFileInfoArr = [FileInfo]()
        var patchFileInfoArr = [FileInfo]()
        
        for fileInfo in fileInfoArr {
            let filePath = fileInfo.filePath
            let file = codingDir.appendingPathComponent(filePath)
            if FileManager.default.fileExists(atPath: file) {
                if fileInfo.modDate == modDate(file) {
                    reserveFileInfoArr.append(fileInfo)
                }
            } else {
                removeFilePathArr.append(filePath)
            }
        }
    
        // 相对self.codingDir的路径
        let files = self.files(dir: codingDir)
        
        for file in files {
            if !reserveFileInfoArr.contains(where: { $0.filePath == file }) {
                let info = FileInfo()
                info.filePath = file
                info.modDate = modDate(codingDir.appendingPathComponent(file)) ?? ""
                patchFileInfoArr.append(info)
            }
        }
        
        // 拷贝patchFileInfoArr里的文件 zip
        let patchDirPath = cleanPatchDir()
        copyFiles(fromDir: codingDir, toDir: patchDirPath, patchFileInfoArr: patchFileInfoArr)
        
        // 将all.json保存进去
        let allJson = (patchFileInfoArr + reserveFileInfoArr).encode() ?? "[]"
        let allJsonFile = patchDirPath.appendingPathComponent("all.json")
        FileManager.default.createFile(atPath: allJsonFile, contents: allJson.data(using: String.Encoding.utf8), attributes: nil)
        // 将remove.json保存进去
        let patchDict = ["removePaths":removeFilePathArr]
        
        let encoder = JSONEncoder()
        if let patchData = try? encoder.encode(patchDict) {
            let patchJsonFile = patchDirPath.appendingPathComponent("patch.json")
            FileManager.default.createFile(atPath: patchJsonFile, contents: patchData, attributes: nil)
        }
        // 压缩patchDirPath,并将压缩后的文件夹保存至服务器目录下
        
        defer {
            let endTime = CACurrentMediaTime()
            print("endDate = ",endTime)
            print("interval = ",endTime - startTime)
            try? FileManager.default.removeItem(atPath: patchDirPath)
        }
        
        return zip(patchDirPath)
    }
    
    func cleanPatchDir() -> String {
        let dir = codingDir.deletingLastPathComponent().appendingPathComponent("patch")
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: dir, isDirectory: &isDir) && isDir.boolValue {
            try? FileManager.default.removeItem(atPath: dir)
        }
        
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        
        return dir
    }
    
    func files(dir: String) -> [String] {
        guard let pathArr = try? FileManager.default.subpathsOfDirectory(atPath: dir) else {
            return []
        }
        
        let files = pathArr.filter { (path) -> Bool in
            var isDir: ObjCBool = true
            return FileManager.default.fileExists(atPath: dir.appendingPathComponent(path), isDirectory: &isDir) && !isDir.boolValue
        }
        
        return files
    }
    
    func md5(_ file: String) -> String? {
        guard let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: file)) else {
            return nil
        }
        
        return data.md5().toHexString()
    }
    
    func modDate(_ file:String) -> String? {
        if let fileAttr = try? FileManager.default.attributesOfItem(atPath: file) {
            if let modeDate = fileAttr[FileAttributeKey.modificationDate] as? Date {
                return modeDate.description
            }
        }
        
        return nil
    }
    
    func copyFiles(fromDir: String, toDir: String, patchFileInfoArr: [FileInfo]) {
        for fileInfo in patchFileInfoArr {
            let origFile = fromDir.appendingPathComponent(fileInfo.filePath)
            let destFile = toDir.appendingPathComponent(fileInfo.filePath)
            var isDir:ObjCBool = false;
            if !FileManager.default.fileExists(atPath: destFile.deletingLastPathComponent(), isDirectory: &isDir) || !isDir.boolValue {
                try? FileManager.default.createDirectory(atPath: destFile.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            }
            try? FileManager.default.copyItem(atPath: origFile, toPath: destFile)
        }
    }
    
    func zip(_ dir: String) -> Bool {
        if codingDir.isEmpty || siteDir.isEmpty {
            print("项目目录和服务器目录不能为空")
            return false
        }
        let zipPath = siteDir.appendingPathComponent(codingDir.lastPathComponent()) + ".zip"
        try? FileManager.default.removeItem(atPath: zipPath)
        return SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: dir)
    }
    
    func findSitesDir() -> String? {
        let ursersDir = "/Users"
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: ursersDir) else {
            return nil
        }
        
        for file in files {
            let path = ursersDir.appendingPathComponent(file)
            if let subfiles = try? FileManager.default.contentsOfDirectory(atPath: path) {
                for subfile in subfiles {
                    if subfile == "LuaGameSites" {
                        return path.appendingPathComponent(subfile)
                    }
                }
            }
        }
        
        return nil
    }
}



extension String {
    func appendingPathComponent(_ path: String) -> String {
        return self + "/" + path
    }
    
    func deletingLastPathComponent() -> String {
        var components = self.components(separatedBy: "/")
        if components.count <= 1 {
            return self
        } else {
            components.removeLast()
            return components.joined(separator: "/")
        }
    }
    
    func lastPathComponent() -> String {
        let components = self.components(separatedBy: "/")
        return components.last ?? ""
    }
}


