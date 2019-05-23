//
//  SettingView.swift
//  LuaGameDebuger
//
//  Created by yuanchao on 2019/5/14.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class SettingView: NSView {
    
    @IBOutlet weak var codingDirTf: NSTextField!
    
    @IBOutlet weak var saveBtn: NSButton!
    
    @IBOutlet weak var patchCheckBox: NSButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.wantsLayer = true
        self.codingDirTf.stringValue = FileHandler.shared.codingDir
        
        self.patchCheckBox.state = FileHandler.shared.isPatch ? NSControl.StateValue.on :  NSControl.StateValue.off
        
    }
    
    @IBAction func saveSetting(_ sender: Any) {
        let codingDir = codingDirTf.stringValue
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: codingDir, isDirectory: &isDir) && isDir.boolValue {
            FileHandler.shared.codingDir = codingDir
        }
        
        FileHandler.shared.isPatch = self.patchCheckBox.state == NSControl.StateValue.on
    }
    
    @IBAction func chooseDir(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        let find = panel.runModal()
        if find == NSApplication.ModalResponse.OK {
            self.codingDirTf.stringValue = panel.url?.absoluteString.replacingOccurrences(of: "file://", with: "") ?? ""
        }
    }
    
    
}

