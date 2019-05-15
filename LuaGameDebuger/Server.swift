//
//  Server.swift
//  LuaGameDebuger
//
//  Created by 袁超 on 2019/5/11.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

enum Command: Int {
    case archive = 100
    case log = 101
    case allFile = 102
    case requestUrl = 103
    case patchZipUrl = 104
}

class Server: NSObject, GCDAsyncSocketDelegate {
    
    let defaultPort: UInt16 = 8090
    
    var clientSocketArr = [GCDAsyncSocket]()
    var rwQueue = DispatchQueue(label: "com.server.rw")
    var socket: GCDAsyncSocket!
    
    static let shared = Server()
    
    private override init() {
        super.init()
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: rwQueue)
    }
    
    func start() {
        do {
            try self.socket.accept(onPort: defaultPort)
        } catch {
            print("连接失败：\(error.localizedDescription)")
        }
    }
    
    func sendMsg(_ msg:String) {
        guard let data = msg.data(using: String.Encoding.utf8) else {
            return
        }
        
        self.clientSocketArr.forEach({ $0.write(data, withTimeout: -1, tag: 100) })
        
    }
    
    // GCDAsyncSocketDelegate
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("didAcceptNewSocket")
        self.clientSocketArr.append(newSocket)
        newSocket.readData(withTimeout: -1, tag: 100)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("did write")
        sock.readData(withTimeout: -1, tag: tag)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("did read")
        self.receivedData(data)
        sock.readData(withTimeout: -1, tag: tag)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if let index = self.clientSocketArr.firstIndex(of: sock) {
            self.clientSocketArr.remove(at: index)
        }
    }
    
}

extension Server {
    func sendArchiveMsg() {
        let msgModel = IMMsgModel()
        msgModel.eventId = Command.archive.rawValue
        var dataDict = Dictionary<String, String>()
        dataDict["resourceId"] = "123456"
        dataDict["resourceUrl"] = "http://"
        let data = try! JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        msgModel.data = String(data: data, encoding: String.Encoding.utf8) ?? ""
        let msg = msgModel.encode() ?? ""
        self.sendMsg(msg)
    }
    
    func sendPatchZipUrlMsg() {
        let msgModel = IMMsgModel()
        msgModel.eventId = Command.patchZipUrl.rawValue
        var dataDict = Dictionary<String, String>()
        dataDict["resourceId"] = "123456"
        dataDict["resourceUrl"] = "http://"
        let data = try! JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        msgModel.data = String(data: data, encoding: String.Encoding.utf8) ?? ""
        let msg = msgModel.encode() ?? ""
        self.sendMsg(msg)
    }
    
    func receivedData(_ data:Data) {
        guard let msgModel = IMMsgModel.decode(json: data), let command = Command(rawValue: msgModel.eventId) else {
            return
        }
        
        switch command  {
        case .allFile:
            if FileHandler.shared.createPatchZip(msgModel.data) {
                self.sendPatchZipUrlMsg()
            }
        default:
            break
        }
    }
}

class IMMsgModel: BaseCodable {
    typealias E = IMMsgModel
    
    var eventId: Int = 0
    var data: String = ""
}
