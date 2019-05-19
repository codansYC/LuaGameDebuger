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
    
    var isPatch = false
    
    func start() {
        Server.shared.ip = getIFAddresses()
        Server.shared.start()
    }
    
    func startGame(_ gameInitInfo: String) {
        FileHandler.shared.gameInitInfo = gameInitInfo
        
        if isPatch {
            
        } else {
            if FileHandler.shared.createZip() {
                sendStartMsg()
            }
        }
    }
    
    func closeGame() {
        Server.shared.sendCloseMsg()
    }
    
    func sendStartMsg() {
        let msgModel = IMMsgModel()
        msgModel.eventId = Command.startGame.rawValue
        var dataDict = Dictionary<String, String>()
//        dataDict["resourceId"] = "123456"
        dataDict["resourceUrl"] = "http://\(Server.shared.ip)/~\(FileHandler.shared.userName)/\(FileHandler.shared.codingDir.lastPathComponent()).zip"
        dataDict["gameInitInfo"] = FileHandler.shared.gameInitInfo
        let data = try! JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        msgModel.data = String(data: data, encoding: String.Encoding.utf8) ?? ""
        let msg = msgModel.encode() ?? ""
        Server.shared.sendMsg(msg)
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
}
