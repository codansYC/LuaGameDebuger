//
//  LogView.swift
//  LuaGameDebuger
//
//  Created by yuanchao on 2019/5/14.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class LogView: NSView, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    @IBOutlet weak var clearBtn: NSButton!
    
    @IBOutlet weak var fliterTextFeild: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    
    var logs: [String] = []
    var fliterLogs: [String] = []
    var displayLogs: [String] {
        return fliterTextFeild.stringValue.isEmpty ? logs : fliterLogs
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.headerView = nil

        Dispatcher.shared.receivedLogCallback = { [unowned self] log in
            self.appendLog(log)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "log"), object: nil, queue: nil) { (noti) in
            if let log = noti.userInfo?["log"] as? String {
                self.appendLog(log)
            }
        }

        tableView.delegate = self
        tableView.dataSource = self
        
        fliterTextFeild.delegate = self
        fliterTextFeild.focusRingType = NSFocusRingType.none
    }
    
    func appendLog(_ log: String) {
        DispatchQueue.main.async {
            self.logs.append(log)
            let fliterKw = self.fliterTextFeild.stringValue
            if !fliterKw.isEmpty && log.contains(fliterKw) {
                self.fliterLogs.append(log)
            }
            self.tableView.insertRows(at: IndexSet.init(integer: self.displayLogs.count-1), withAnimation: NSTableView.AnimationOptions.init(rawValue: 0))
        }
    }
    
    @IBAction func clearLogs(_ btn: NSButton? = nil) {
        logs.removeAll()
        fliterLogs.removeAll()
        tableView.reloadData()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return displayLogs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) as? NSTableCellView
        
        cellView?.textField?.stringValue = displayLogs[row]
        cellView?.textField?.maximumNumberOfLines = Int.max
        
        return cellView
    }
    
    func controlTextDidChange(_ obj: Notification) {
        fliter()
    }
    
    func fliter() {
        if fliterTextFeild.stringValue.isEmpty {
            fliterLogs.removeAll()
            tableView.reloadData()
            return
        }
        
        fliterLogs = logs.filter({ $0.contains(fliterTextFeild.stringValue) })
        tableView.reloadData()
    }
}

class LogCell: NSTableCellView {
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


