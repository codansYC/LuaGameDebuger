//
//  DebugView.swift
//  LuaGameDebuger
//
//  Created by 袁超 on 2019/5/18.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class DebugView: NSView, NSTextViewDelegate {
    
    @IBOutlet weak var textView: NSTextView!
    
    @IBOutlet weak var placeholderLabel: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.string = FileHandler.shared.gameInitInfo
        textView.delegate = self
    }
    
    @IBAction func startGame(sender: Any) {
        let info = self.textView.string
        if !Server.shared.hasClientConnected {
            Dispatcher.postLog("没有客户端连接")
            return
        }
        
        Dispatcher.shared.startGame(info)
    }
    
    
    @IBAction func closeGame(sender: Any) {
        Dispatcher.shared.closeGame()
    }
    
    func textDidChange(_ notification: Notification) {
        placeholderLabel.isHidden = !textView.string.isEmpty
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
