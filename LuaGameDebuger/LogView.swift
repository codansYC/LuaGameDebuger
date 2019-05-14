//
//  LogView.swift
//  LuaGameDebuger
//
//  Created by yuanchao on 2019/5/14.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class LogView: NSView {
    
    @IBOutlet weak var clearBtn: NSButton!
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
