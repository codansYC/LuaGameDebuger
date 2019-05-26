//
//  SettingView.swift
//  LuaGameDebuger
//
//  Created by yuanchao on 2019/5/14.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa
import SnapKit

class SettingView: NSView {
    
    let codingDirTf = NSTextField()
    let patchCheckBox = NSButton(checkboxWithTitle: "增量更新", target: nil, action: nil)
    
    init() {
        super.init(frame: NSRect.zero)
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        setUpViews()
        
        self.codingDirTf.stringValue = FileHandler.shared.codingDir
        
        self.patchCheckBox.state = FileHandler.shared.isPatch ? NSControl.StateValue.on :  NSControl.StateValue.off
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        let codingDirLabel = NSTextField(string: "打包目录")
        codingDirLabel.isEditable = false
        codingDirLabel.isBordered = false
        codingDirLabel.backgroundColor = NSColor.clear
        let chooseBtn = NSButton(title: "选择目录", target: self, action: #selector(SettingView.chooseDir))
        let saveBtn = NSButton(title: "保存设置", target: self, action: Selector(("saveSetting")))
        
        addSubview(codingDirLabel)
        addSubview(codingDirTf)
        addSubview(chooseBtn)
        addSubview(patchCheckBox)
        addSubview(saveBtn)
        
        codingDirLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(30)
            make.width.equalTo(60)
        }
        
        codingDirTf.snp.makeConstraints { (make) in
            make.left.equalTo(codingDirLabel.snp.right).offset(5)
            make.centerY.equalTo(codingDirLabel)
            make.right.equalTo(chooseBtn.snp.left)
        }
        chooseBtn.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.right.equalTo(-20)
            make.centerY.equalTo(codingDirLabel)
        }
        patchCheckBox.snp.makeConstraints { (make) in
            make.left.equalTo(codingDirLabel)
            make.top.equalTo(codingDirLabel.snp.bottom).offset(30)
        }
        saveBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-30)
            make.centerX.equalTo(self)
        }
    }
    
    func saveSetting() {
        let codingDir = codingDirTf.stringValue
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: codingDir, isDirectory: &isDir) && isDir.boolValue {
            FileHandler.shared.codingDir = codingDir
        }
        
        FileHandler.shared.isPatch = self.patchCheckBox.state == NSControl.StateValue.on
    }
    
    @objc func chooseDir() {
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

