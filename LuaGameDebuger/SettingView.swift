//
//  SettingView.swift
//  LuaGameDebuger
//
//  Created by yuanchao on 2019/5/14.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class SettingView: NSView {
    
    @IBOutlet weak var siteDirTf: NSTextField!
    
    @IBOutlet weak var codingDirTf: NSTextField!
    
    @IBOutlet weak var saveBtn: NSButton!
    
    @IBOutlet weak var patchCheckBox: NSButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.wantsLayer = true
        self.siteDirTf.stringValue = FileHandler.shared.siteDir
        self.codingDirTf.stringValue = FileHandler.shared.codingDir
        
        self.patchCheckBox.state = NSControl.StateValue.off
    }
    
    @IBAction func saveSetting(_ sender: Any) {
        let codingDir = codingDirTf.stringValue
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: codingDir, isDirectory: &isDir) && isDir.boolValue {
            FileHandler.shared.codingDir = codingDir
        }
        
        let siteDir = siteDirTf.stringValue
        if FileManager.default.fileExists(atPath: siteDir, isDirectory: &isDir) && isDir.boolValue {
            FileHandler.shared.siteDir = siteDir
        }
        
        FileHandler.shared.isPatch = self.patchCheckBox.state == NSControl.StateValue.on
    }
    
}
