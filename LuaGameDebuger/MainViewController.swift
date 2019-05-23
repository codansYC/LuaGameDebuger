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
    
    @IBOutlet weak var settingView: SettingView!
    
    @IBOutlet weak var gameInfoView: GameInfoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.containerView.wantsLayer = true;
        self.containerView.layer?.backgroundColor = NSColor.white.cgColor;
        
        Dispatcher.shared.start()
        
        createCode()
        
        showLog(logBtn)
        
    }
    
    @IBAction func showLog(_ sender: Any) {
        self.logView.isHidden = false
        self.settingView.isHidden = true
        self.gameInfoView.isHidden = true
    }
    
    @IBAction func setting(_ sender: Any) {
        self.logView.isHidden = true
        self.settingView.isHidden = false
        self.gameInfoView.isHidden = true
    }
    
    @IBAction func startGame(_ sender: Any) {
        self.logView.isHidden = true
        self.settingView.isHidden = true
        self.gameInfoView.isHidden = false
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
        /**
         *  3.恢复滤镜默认设置
         */
//        [filter setDefaults];
        
        /**
         *  4.设置数据(通过滤镜对象的KVC)
         */
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
        
        /**
         *  5.生成二维码
         */
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




