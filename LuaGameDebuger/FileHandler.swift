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
    
    var userName = ""
    
    var isPatch = false {
        didSet {

        }
    }
    
    var gameInitInfo = "" {
        didSet {
            UserDefaults.standard.set(gameInitInfo, forKey: "gameInitInfo")
        }
    }
    
    private init() {
        self.codingDir = UserDefaults.standard.string(forKey: "codingDir") ?? ""
        self.siteDir = findSitesDir() ?? ""
        
        let arr = self.siteDir.split(separator: "/")
        if arr.count == 3 {
            self.userName = String(arr[1])
        }
    }
    
    func createZip() -> Bool {
        return zip(self.codingDir)
    }
    
    func createPatchZip(_ allFileJson: String) -> Bool {
        let fileInfoArr = [FileInfo].decode(json: allFileJson) ?? []
        
        var removeFilePathArr = [String]()
        var reserveFileInfoArr = [FileInfo]()
        var patchFileInfoArr = [FileInfo]()
        
        for fileInfo in fileInfoArr {
            let filePath = fileInfo.filePath!
            let file = self.codingDir.appendingPathComponent(filePath)
            if FileManager.default.fileExists(atPath: file) {
                if md5(file) == fileInfo.md5 {
                    reserveFileInfoArr.append(fileInfo)
                }
            } else {
                removeFilePathArr.append(filePath)
            }
        }
        
        // 相对self.codingDir的路径
        let files = self.files(dir: self.codingDir)
        
        for file in files {
            if !reserveFileInfoArr.contains(where: { $0.filePath == file }) {
                let info = FileInfo()
                info.filePath = file
                info.md5 = md5(self.codingDir.appendingPathComponent(file))
                patchFileInfoArr.append(info)
            }
        }
        
        // 拷贝patchFileInfoArr里的文件 zip
        let patchDirPath = self.copyFiles(dir: self.codingDir, patchFileInfoArr: patchFileInfoArr)
        // 将all.json保存进去
        let allJson = (patchFileInfoArr + reserveFileInfoArr).encode() ?? "[]"
        let allJsonFile = patchDirPath.appendingPathComponent("all.json")
        FileManager.default.createFile(atPath: allJsonFile, contents: allJson.data(using: String.Encoding.utf8), attributes: nil)
        // 将remove.json保存进去
        let encoder = JSONEncoder()
        if let removeData = try? encoder.encode(removeFilePathArr) {
            let removeJsonFile = patchDirPath.appendingPathComponent("remove.json")
            FileManager.default.createFile(atPath: removeJsonFile, contents: removeData, attributes: nil)
        }
        // 压缩patchDirPath,并将压缩后的文件夹保存至服务器目录下
        
        defer {
            try? FileManager.default.removeItem(atPath: patchDirPath)
        }
        
        return self.zip(patchDirPath)
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
    
    func copyFiles(dir: String, patchFileInfoArr: [FileInfo]) -> String {
        let destDir = dir.deletingLastPathComponent().appendingPathComponent("patch")
        
        for fileInfo in patchFileInfoArr {
            let origFile = dir.appendingPathComponent(fileInfo.filePath!)
            let destFile = destDir.appendingPathComponent(fileInfo.filePath!)
            var isDir:ObjCBool = false;
            if !FileManager.default.fileExists(atPath: destFile.deletingLastPathComponent(), isDirectory: &isDir) || !isDir.boolValue {
                try? FileManager.default.createDirectory(atPath: destFile.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            }
            try? FileManager.default.copyItem(atPath: origFile, toPath: destFile)
        }
        
        return destDir
    }
    
    func zip(_ dir: String) -> Bool {
        if self.codingDir.isEmpty || self.siteDir.isEmpty {
            print("项目目录和服务器目录不能为空")
            return false
        }
        let zipPath = self.siteDir.appendingPathComponent(self.codingDir.lastPathComponent()) + ".zip"
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
                    if subfile == "Sites" {
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


