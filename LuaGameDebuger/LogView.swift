//
//  LogView.swift
//  LuaGameDebuger
//
//  Created by yuanchao on 2019/5/14.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa

class LogView: NSView, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var clearBtn: NSButton!
    
    @IBOutlet weak var tableView: NSTableView!
    
    var logs: [String] = []
    
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
        
    }
    
    func appendLog(_ log: String) {
        DispatchQueue.main.async {
            self.logs.append(log)
            self.tableView.insertRows(at: IndexSet.init(integer: self.logs.count-1), withAnimation: NSTableView.AnimationOptions.init(rawValue: 0))
        }
    }
    
    @IBAction func clearLogs(_ btn: NSButton? = nil) {
        logs.removeAll()
        tableView.reloadData()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) as? NSTableCellView
        
        cellView?.textField?.stringValue = logs[row]
        cellView?.textField?.maximumNumberOfLines = Int.max
        
        cellView?.wantsLayer = true
//        cellView?.layer?.backgroundColor = row % 2 == 1 ? NSColor.white.cgColor : NSColor.init(calibratedRed: 233 / 255.0, green: 233 / 255.0, blue: 233 / 255.0, alpha: 1).cgColor
        
        return cellView
    }
    

    
}

class LogCell: NSTableCellView {
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


