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

    @IBOutlet weak var codeBtn: NSButton!
    
    @IBOutlet weak var logBtn: NSButton!
    
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var codeImageView: NSImageView!
    
    @IBOutlet weak var logView: LogView!
    
    @IBOutlet weak var settingView: SettingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.containerView.wantsLayer = true; self.containerView.layer?.backgroundColor = NSColor.white.cgColor;
        
        Server.shared.start()
        
        let path = ""
    
        let url = URL.init(fileURLWithPath: path)
        do {
            let data = try Data.init(contentsOf: url)
            print(data.md5().toHexString())
        } catch {
            print(error)
        }
    }

    @IBAction func showCode(_ sender: Any) {
        self.codeImageView.isHidden = false
        self.logView.isHidden = true
        self.settingView.isHidden = true
        
        self.createCode()
    }
    
    @IBAction func showLog(_ sender: Any) {
        self.codeImageView.isHidden = true
        self.logView.isHidden = false
        self.settingView.isHidden = true
    }
    
    @IBAction func setting(_ sender: Any) {
        self.codeImageView.isHidden = true
        self.logView.isHidden = true
        self.settingView.isHidden = false
    }
    
    @IBAction func archive(_ sender: Any) {
        Server.shared.sendArchiveMsg()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func getIFAddresses() -> String {
        var addresses = [String]()
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr?.pointee
            while ptr != nil {
                if let flags = ptr?.ifa_flags, let addr = ptr?.ifa_addr {
                    if (Int32(flags) & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                        if addr.pointee.sa_family == UInt8(AF_INET) || addr.pointee.sa_family == UInt8(AF_INET6) {
                        
                            var hostname = [CChar].init(repeating: 0, count: 100)
                            if getnameinfo(addr, socklen_t(addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                                let address = String.init(cString: hostname)
                                addresses.append(address)
                            }
                            
                        }
                    }
                    ptr = ptr?.ifa_next?.pointee
                }
                
            }
            
            freeifaddrs(ifaddr)
        }
        
        for s in addresses {
            let a = s.split(separator: ".")
            if a.count == 4 {
                return s
            }
        }
        
        return ""
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
        var info = getIFAddresses()
        if info == "" {
            info = "no wifi"
        }
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
                let image = NSImage(cgImage: cgImage, size: NSSize(width: 150, height: 150))
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




