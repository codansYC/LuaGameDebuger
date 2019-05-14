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
    
    var codingDir = ""
    var siteDir = ""
    
    private init() {
    }
    
    func createPatchZip(allJson: String) {
        // all.json
        // patch.json
        let projectDir = "" // 文件根目录
        
        var removeFilePathArr = [String]()
        var reserveFileInfoArr = [FileInfo]()
        var patchFileInfoArr = [FileInfo]()
        
        if let fileInfoArr = [FileInfo].decode(json: allJson) {
            for fileInfo in fileInfoArr {
                let filePath = fileInfo.filePath!
                let file = projectDir.appendingPathComponent(filePath)
                if FileManager.default.fileExists(atPath: file) {
                    if md5(file) == fileInfo.md5 {
                        reserveFileInfoArr.append(fileInfo)
                    }
                } else {
                    removeFilePathArr.append(filePath)
                }
            }
        }
        
        let files = self.files(dir: projectDir)
        
        for file in files {
            let reletivePath = file.replacingOccurrences(of: projectDir + "/", with: "")
            if !reserveFileInfoArr.contains(where: { $0.filePath == reletivePath }) {
                let info = FileInfo()
                info.filePath = reletivePath
                info.md5 = md5(file)
                patchFileInfoArr.append(info)
            }
        }
        
        // 拷贝patchFileInfoArr里的文件 zip
        let patchDirPath = self.copyFiles(dir: projectDir, patchFileInfoArr: patchFileInfoArr)
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
        // 压缩patchDirPath
        // 将压缩后的文件夹保存至服务器目录下
    }
    
    func files(dir: String) -> [String] {
        guard let pathArr = try? FileManager.default.contentsOfDirectory(atPath: dir) else {
            return []
        }
        
        let files = pathArr.filter { (path) -> Bool in
            var isDir: ObjCBool = true
            return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue
        }
        
        return files
    }
    
    func md5(_ file: String) -> String? {
        guard let url = URL.init(string: file), let data = try? Data.init(contentsOf: url) else {
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
    
    func zip(dir: String) -> String {
        return ".zip"
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
}


