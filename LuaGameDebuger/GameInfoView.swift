//
//  GameInfoView.swift
//  LuaGameDebuger
//
//  Created by 袁超 on 2019/5/18.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class GameInfoView: NSView {

    @IBOutlet weak var textView: NSTextView!
    
    @IBOutlet weak var controlBtn: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.wantsLayer = true
        self.textView.layer?.backgroundColor = NSColor.init(calibratedRed: 233 / 255.0, green: 233 / 255.0, blue: 233 / 255.0, alpha: 1).cgColor
        self.textView.needsDisplay = true;
        
        self.textView.string = UserDefaults.standard.string(forKey: "gameInitInfo") ?? ""
        
    }
    
    @IBAction func startGame(_ btn: NSButton) {
        let info = self.textView.string
        if !Server.shared.hasClientConnected {
            print("没有与客户端建立连接")
            return
        }
        
        Dispatcher.shared.startGame(info)
    }
    
    @IBAction func closeGame(_ btn: NSButton) {
        Dispatcher.shared.closeGame()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
