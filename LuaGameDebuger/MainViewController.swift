//
//  MainViewController.swift
//  LuaGameDebuger
//
//  Created by yuanchao on 2019/5/8.
//  Copyright © 2019年 yuanchao. All rights reserved.
//

import Cocoa
import CryptoSwift

class MainViewController: NSViewController {
    
    @IBOutlet weak var logBtn: NSButton!
    
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var codeImageView: NSImageView!
    
    @IBOutlet weak var logView: LogView!
    
    let settingView = SettingView()
    
    @IBOutlet weak var debugView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpViews()
        
        Dispatcher.shared.start()
        
        createCode()
        
        showLog(logBtn)
        
    }
    
    func setUpViews() {
        containerView.addSubview(settingView)
        settingView.isHidden = true
        settingView.snp.makeConstraints { (make) in
            make.edges.equalTo(NSEdgeInsetsMake(20, 0, 20, 20))
        }
        
        containerView.addSubview(debugView)
        debugView.isHidden = true
        debugView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
    @IBAction func showLog(_ sender: Any) {
        self.logView.isHidden = false
        self.settingView.isHidden = true
        self.debugView.isHidden = true
    }
    
    @IBAction func setting(_ sender: Any) {
        self.logView.isHidden = true
        self.settingView.isHidden = false
        self.debugView.isHidden = true
    }
    
    @IBAction func startGame(_ sender: Any) {
        self.logView.isHidden = true
        self.settingView.isHidden = true
        self.debugView.isHidden = false
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func createCode() {
        //生成CIFilter(滤镜)对象
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
       
        //存放的信息
        let ip = Server.shared.ip
        let port = Server.shared.defaultPort
        let info = """
        {"ip":"\(ip)","port":\(port)}
        """
        
        //把信息转化为NSData
        let infoData = info.data(using: String.Encoding.utf8)
        
        //滤镜对象kvc存值
        filter?.setValue(infoData, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        if let outImage = filter?.outputImage {
            if let cgImage = self.convertCIImageToCGImage(ciImage: outImage) {
                let image = NSImage(cgImage: cgImage, size: NSSize(width: 82, height: 82))
                self.codeImageView.image = image;
            }
        }
        
    }
    
    func convertCIImageToCGImage(ciImage:CIImage) -> CGImage? {
        let ciContext = CIContext.init()
        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
        return cgImage
    }
}




