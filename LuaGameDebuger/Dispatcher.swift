//
//  Dispatcher.swift
//  LuaGameDebuger
//
//  Created by 袁超 on 2019/5/19.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class Dispatcher {
    
    static let shared = Dispatcher()
    
    var scriptObj: NSAppleScript?
    
    var isPatch: Bool {
        return FileHandler.shared.isPatch
    }
    
    var requestAllJsonCallback: ((String)->Void)?
    
    var resourceUrl: String {
//        return "http://luagame.com/\(FileHandler.shared.codingDir.lastPathComponent()).zip"
        return "http://\(Server.shared.ip)/~\(FileHandler.shared.userName)/\(FileHandler.shared.codingDir.lastPathComponent()).zip"
    }
    
    var receivedLogCallback: ((String)->(Void))?
    
    func start() {
        Server.shared.ip = getIFAddresses()
        Server.shared.start()
    }
    
    private init() {
        Server.shared.receivedMsgCallback = { [unowned self] msg in
            guard let command = Command(rawValue: msg.eventId) else {
                return
            }
            
            switch command {
            case .log:
                let log = msg.data
                self.receivedLogCallback?(log)
            case .requestResource:   // 业务中的游戏
                if self.isPatch {
                    self.requestAllJson(callback: { json in
                        _ = FileHandler.shared.createPatchZip(json)
                        self.responseResource()
                    })
                } else {
                    _ = FileHandler.shared.createZip()
                    self.responseResource()
                }
            case .responseAllJson:
                let allJson = msg.data
                self.requestAllJsonCallback?(allJson)
                self.requestAllJsonCallback = nil
            default:
                break
            }
        }
    }
    
    func startGame(_ gameInitInfo: String) {
        FileHandler.shared.gameInitInfo = gameInitInfo
        
        if isPatch {
            // 请求alljson
            // 根据alljson打增量包
            // sendStartMsg
            requestAllJson { [unowned self] json in
                if FileHandler.shared.createPatchZip(json) {
                    self.sendStartMsg()
                }
            }
        } else {
            if FileHandler.shared.createZip() {
                sendStartMsg()
            }
        }
    }
    
    func closeGame() {
        sendCloseMsg()
    }
    
    func sendStartMsg() {
        let msgModel = IMMsgModel()
        msgModel.eventId = Command.startGame.rawValue
        var dataDict = Dictionary<String, String>()
        dataDict["resourceUrl"] = self.resourceUrl
        dataDict["gameInitInfo"] = FileHandler.shared.gameInitInfo
        let data = try! JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        msgModel.data = String(data: data, encoding: String.Encoding.utf8) ?? ""
        Server.shared.sendMsg(msgModel)
    }
    
    func sendCloseMsg() {
        let msgModel = IMMsgModel()
        msgModel.eventId = Command.closeGame.rawValue
        msgModel.data = ""
        Server.shared.sendMsg(msgModel)
    }
    
    func requestAllJson(callback:@escaping ((String)->(Void))) {
        self.requestAllJsonCallback = callback
        let msgModel = IMMsgModel()
        msgModel.eventId = Command.requestAllJson.rawValue
        var dataDict = Dictionary<String, String>()
        dataDict["resourceUrl"] = self.resourceUrl
        let data = try! JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        msgModel.data = String(data: data, encoding: String.Encoding.utf8) ?? ""
        Server.shared.sendMsg(msgModel)
    }
    
    func responseResource() {
        let msgModel = IMMsgModel()
        msgModel.eventId = Command.responseResource.rawValue
        var dataDict = Dictionary<String, String>()
        dataDict["resourceUrl"] = self.resourceUrl
        dataDict["isPatch"] = self.isPatch ? "1" : "0"
        let data = try! JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        msgModel.data = String(data: data, encoding: String.Encoding.utf8) ?? ""
        Server.shared.sendMsg(msgModel)
    }
    
    func getIFAddresses() -> String {
        var addresses = [String]()
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr?.pointee
            while ptr != nil {
                if let flags = ptr?.ifa_flags, let addr = ptr?.ifa_addr {
                    if (Int32(flags) & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                        if addr.pointee.sa_family == UInt8(AF_INET) || addr.pointee.sa_family == UInt8(AF_INET6) {
                            
                            var hostname = [CChar].init(repeating: 0, count: 100)
                            if getnameinfo(addr, socklen_t(addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                                let address = String.init(cString: hostname)
                                addresses.append(address)
                            }
                            
                        }
                    }
                    ptr = ptr?.ifa_next?.pointee
                }
                
            }
            
            freeifaddrs(ifaddr)
        }
        
        for s in addresses {
            let a = s.split(separator: ".")
            if a.count == 4 {
                return s
            }
        }
        
        return ""
    }
    
    class func postLog(_ log: String) {
        let dateStr = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 8 * 60 * 60).description.replacingOccurrences(of: "+0000", with: "")
        let logDesc = "[调试器]" + dateStr + log
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "log"), object: nil, userInfo: ["log":logDesc])
    }
    
    class func alert(_ msg: String) {
        let alert = NSAlert()
        alert.messageText = msg
        alert.addButton(withTitle: "知道了")
        alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { (res) in
            
        }
    }
}


