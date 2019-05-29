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
    
    @IBOutlet weak var filterTextFeild: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    
    var logs: [String] = []
    var filterLogs: [String] = []
    var displayLogs: [String] {
        return filterTextFeild.stringValue.isEmpty ? logs : filterLogs
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
        
        filterTextFeild.delegate = self
        filterTextFeild.focusRingType = NSFocusRingType.none
    }
    
    func appendLog(_ log: String) {
        DispatchQueue.main.async {
            self.logs.append(log)
            let filterKw = self.filterTextFeild.stringValue
            if !filterKw.isEmpty && log.contains(filterKw) {
                self.filterLogs.append(log)
            }
            self.tableView.insertRows(at: IndexSet.init(integer: self.displayLogs.count-1), withAnimation: NSTableView.AnimationOptions.init(rawValue: 0))
        }
    }
    
    @IBAction func clearLogs(_ btn: NSButton? = nil) {
        logs.removeAll()
        filterLogs.removeAll()
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
        if row < displayLogs.count {
            cellView?.textField?.stringValue = displayLogs[row]
            cellView?.textField?.maximumNumberOfLines = Int.max
        }
        return cellView
    }
    
    func controlTextDidChange(_ obj: Notification) {
        filter()
    }
    
    func filter() {
        if filterTextFeild.stringValue.isEmpty {
            filterLogs.removeAll()
            tableView.reloadData()
            return
        }
        
        filterLogs = logs.filter({ $0.contains(filterTextFeild.stringValue) })
        tableView.reloadData()
    }
}

class LogCell: NSTableCellView {
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


