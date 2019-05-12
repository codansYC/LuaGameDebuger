//
//  Server.swift
//  LuaGameDebuger
//
//  Created by 袁超 on 2019/5/11.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

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
    
    // GCDAsyncSocketDelegate
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("didAcceptNewSocket")
        self.clientSocketArr.append(newSocket)
        newSocket.readData(withTimeout: -1, tag: 100)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("did write")
        sock.readData(withTimeout: -1, tag: 100)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let info = String.init(data: data, encoding: String.Encoding.utf8)
        
        print("did read:\(String(describing: info)))")
    }
    
    
    
}
