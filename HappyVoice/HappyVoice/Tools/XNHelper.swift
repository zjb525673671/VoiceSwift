//
//  XNHelper.swift
//  HappyVoice
//
//  Created by 周结兵 on 2019/10/30.
//  Copyright © 2019 周结兵. All rights reserved.
//

import UIKit
import CommonCrypto

class XNHelper: NSObject {
    class func iphoneType() ->String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
                return String(cString: ptr)
            }
        if platform == "iPhone1,1" { return "iPhone 2G"}
        if platform == "iPhone1,2" { return "iPhone 3G"}
        if platform == "iPhone2,1" { return "iPhone 3GS"}
        if platform == "iPhone3,1" { return "iPhone 4"}
        if platform == "iPhone3,2" { return "iPhone 4"}
        if platform == "iPhone3,3" { return "iPhone 4"}
        if platform == "iPhone4,1" { return "iPhone 4S"}
        if platform == "iPhone5,1" { return "iPhone 5"}
        if platform == "iPhone5,2" { return "iPhone 5"}
        if platform == "iPhone5,3" { return "iPhone 5C"}
        if platform == "iPhone5,4" { return "iPhone 5C"}
        if platform == "iPhone6,1" { return "iPhone 5S"}
        if platform == "iPhone6,2" { return "iPhone 5S"}
        if platform == "iPhone7,1" { return "iPhone 6 Plus"}
        if platform == "iPhone7,2" { return "iPhone 6"}
        if platform == "iPhone8,1" { return "iPhone 6S"}
        if platform == "iPhone8,2" { return "iPhone 6S Plus"}
        if platform == "iPhone8,4" { return "iPhone SE"}
        if platform == "iPhone9,1" { return "iPhone 7"}
        if platform == "iPhone9,2" { return "iPhone 7 Plus"}
        if platform == "iPhone10,1" { return "iPhone 8"}
        if platform == "iPhone10,2" { return "iPhone 8 Plus"}
        if platform == "iPhone10,3" { return "iPhone X"}
        if platform == "iPhone10,4" { return "iPhone 8"}
        if platform == "iPhone10,5" { return "iPhone 8 Plus"}
        if platform == "iPhone10,6" { return "iPhone X"}
        if platform == "iPhone11,2" { return "iPhone XS"}
        if platform == "iPhone11,4" { return "iPhone XS Max (China)"}
        if platform == "iPhone11,6" { return "iPhone XS Max (China)"}
        if platform == "iPhone11,8" { return "iPhone XR"}

        if platform == "iPod1,1" { return "iPod Touch 1G"}
        if platform == "iPod2,1" { return "iPod Touch 2G"}
        if platform == "iPod3,1" { return "iPod Touch 3G"}
        if platform == "iPod4,1" { return "iPod Touch 4G"}
        if platform == "iPod5,1" { return "iPod Touch 5G"}
        
        if platform == "iPad1,1" { return "iPad 1"}
        if platform == "iPad2,1" { return "iPad 2"}
        if platform == "iPad2,2" { return "iPad 2"}
        if platform == "iPad2,3" { return "iPad 2"}
        if platform == "iPad2,4" { return "iPad 2"}
        if platform == "iPad2,5" { return "iPad Mini 1"}
        if platform == "iPad2,6" { return "iPad Mini 1"}
        if platform == "iPad2,7" { return "iPad Mini 1"}
        if platform == "iPad3,1" { return "iPad 3"}
        if platform == "iPad3,2" { return "iPad 3"}
        if platform == "iPad3,3" { return "iPad 3"}
        if platform == "iPad3,4" { return "iPad 4"}
        if platform == "iPad3,5" { return "iPad 4"}
        if platform == "iPad3,6" { return "iPad 4"}
        if platform == "iPad4,1" { return "iPad Air"}
        if platform == "iPad4,2" { return "iPad Air"}
        if platform == "iPad4,3" { return "iPad Air"}
        if platform == "iPad4,4" { return "iPad Mini 2"}
        if platform == "iPad4,5" { return "iPad Mini 2"}
        if platform == "iPad4,6" { return "iPad Mini 2"}
        if platform == "iPad4,7" { return "iPad Mini 3"}
        if platform == "iPad4,8" { return "iPad Mini 3"}
        if platform == "iPad4,9" { return "iPad Mini 3"}
        if platform == "iPad5,1" { return "iPad Mini 4"}
        if platform == "iPad5,2" { return "iPad Mini 4"}
        if platform == "iPad5,3" { return "iPad Air 2"}
        if platform == "iPad5,4" { return "iPad Air 2"}
        if platform == "iPad6,3" { return "iPad Pro 9.7"}
        if platform == "iPad6,4" { return "iPad Pro 9.7"}
        if platform == "iPad6,7" { return "iPad Pro 12.9"}
        if platform == "iPad6,8" { return "iPad Pro 12.9"}
        
        if platform == "i386"   { return "iPhone Simulator"}
        if platform == "x86_64" { return "iPhone Simulator"}
        return platform
    }
    
    /// 获取iPhone名称
    class func iphoneName() -> String {
        return UIDevice.current.name
    }

    /// 获取app版本号
    class func appVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    /// 获取电池电量
    class func batteryLevel() -> CGFloat {
        return CGFloat(UIDevice.current.batteryLevel)
    }

    /// 当前系统名称
    class func systemName() -> String {
        return UIDevice.current.systemName
    }

    /// 当前系统版本号
    class func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }

    /// 通用唯一识别码UUID
    class func UUID() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }

    /// 获取当前设备IP
    class func deviceIDFA() -> String? {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }

    /// 私有方法
    class func blankof<T>(type:T.Type) -> T {
        let ptr = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
        let val = ptr.pointee
        ptr.deinitialize(count: 0)
        return val
    }

    /// 获取总内存大小
    class func totalRAM() -> Int64 {
        var fs = XNHelper.blankof(type: statfs.self)
        if statfs("/var",&fs) >= 0{
            return Int64(UInt64(fs.f_bsize) * fs.f_blocks)
        }
        return -1
    }

    /// 获取当前可用内存
    class func availableRAM() -> Int64 {
        var fs = XNHelper.blankof(type: statfs.self)
        if statfs("/var",&fs) >= 0{
            return Int64(UInt64(fs.f_bsize) * fs.f_bavail)
        }
        return -1
    }

    /// 获取电池当前的状态，共有4种状态
    class func batteryState() -> String {
        let device = UIDevice.current
        if device.batteryState == UIDevice.BatteryState.unknown {
            return "unknown"
        } else if device.batteryState == UIDevice.BatteryState.unplugged {
            return "unplugged"
        } else if device.batteryState == UIDevice.BatteryState.charging {
            return "charging"
        } else if device.batteryState == UIDevice.BatteryState.full {
            return "full"
        }
        return ""
    }

    /// 获取当前语言
    func deviceLanguage() -> String {
        return Locale.preferredLanguages[0]
    }
    
    /// MD5加密
    class func md5(strs:String) ->String!{
      let str = strs.cString(using: String.Encoding.utf8)
      let strLen = CUnsignedInt(strs.lengthOfBytes(using: String.Encoding.utf8))
      let digestLen = Int(CC_MD5_DIGEST_LENGTH)
      let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
      CC_MD5(str!, strLen, result)
      let hash = NSMutableString()
      for i in 0 ..< digestLen {
          hash.appendFormat("%02x", result[i])
      }
      result.deinitialize(count: 32)
      return String(format: hash as String)
    }
    
    class func dictionaryToJSONString(dict:Dictionary<String, Any>?)->String {
        let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }

    class func help_dic(sign:String, url:String) -> String {
        var dic: [String: Any] = [String : Any]()
        dic["appVersion"] = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        dic["phoneVersion"] = UIDevice.current.systemVersion
        dic["phoneType"] = XNHelper.iphoneType()
        dic["deviceId"] = XNHelper.UUID()
        dic["uid"] = XNUserInfo.uid
        dic["channel"] = "appstore"
        dic["device_idfa"] = XNHelper.deviceIDFA()
        dic["talkVersion"] = "0"
        dic["os"] = "ios"
        dic["appFrom"] = "2"
        dic["timestamp"] = String(format: "%.f", Date().timeIntervalSince1970*1000)
        dic["sign"] = XNHelper.md5(strs: String(format: "%@%@%@%@", url,String(format: "%.f", Date().timeIntervalSince1970*1000),"aHVvYmFuamlheW91txrenVrZWppYXlvdQ==",sign))?.lowercased()
        print("公共参数:\(dic)")
        return XNHelper.dictionaryToJSONString(dict:dic as Dictionary)
    }
}


extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
}
