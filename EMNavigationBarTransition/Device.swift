//
//  Device.swift
//  emarketing-ios
//
//  Created by jiafeng wu on 2018/6/12.
//  Copyright © 2018年 jiafeng wu. All rights reserved.
//

import UIKit

/// 设备信息
struct DeviceInfo {
    
    /// 设备名称
    static var deviceName: Device {
        return Device()
    }
    
    /// 设备唯一标示符
    static var deviceUUID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

extension DeviceInfo {
    
    /// 判断设备型号
    enum Device {
        /*** iPhone ***/
        case simulator
        case iPhone4
        case iPhone4S
        case iPhone5
        case iPhone5C
        case iPhone5S
        case iPhone6
        case iPhone6Plus
        case iPhone6s
        case iPhone6sPlus
        case iPhoneSE
        case iPhone7
        case iPhone7Plus
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        /*** iPad ***/
        case iPad1
        case iPad2
        case iPad3
        case iPad4
        case iPad5
        case iPadAir
        case iPadAir2
        case iPadMini
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPadPro12_9Inch
        case iPadPro10_5Inch
        case iPadPro9_7Inch
        
        // Screen 320 * 480
        // iPhone SE, iPhone 5c, iPhone 5s, iPhone 5
        case iPhoneSmall
        // Screen 375 * 667
        // iPhone 6, iPhone 7, iPhone 8
        case iPhone
        // Screen 414 * 736
        // iPhone 6Plus, iPhone 7Plus, iPhone 8Plus
        case iPhonePlus
        // Screen 375 * 812
        // iPhone X
        case iPhoneXSimulator
        
        /// 375 * 667
        static let iPhoneHeight: CGFloat = 667.0
        /// 414 * 736
        static let iPhonePlusHeight: CGFloat = 736.0
        /// 320 * 568
        static let iPhoneSmallHeight: CGFloat = 568.0
        /// 375 * 812
        static let iPhoneXHeight: CGFloat = 812.0
        
        init() {
            let code = Device.getCode()
            self = Device.mapToDevice(code: code)
        }
        
        /// 获取设备识别码
        private static func getCode() -> String {
            var systemInfo = utsname()
            uname(&systemInfo)
            
            let Code: String = String(validatingUTF8: NSString(bytes: &systemInfo.machine,
                                                               length: Int(_SYS_NAMELEN),
                                                               encoding: String.Encoding.ascii.rawValue)!.utf8String!)!
            
            return Code
        }
        
        fileprivate static func mapToDevice(code: String) -> Device {
            switch code {
                /*** iPhone ***/
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":
                return .iPhone4
            case "iPhone4,1", "iPhone4,2", "iPhone4,3":
                return .iPhone4S
            case "iPhone5,1", "iPhone5,2":
                return .iPhone5
            case "iPhone5,3", "iPhone5,4":
                return .iPhone5C
            case "iPhone6,1", "iPhone6,2":
                return .iPhone5S
            case "iPhone7,2":
                return .iPhone6
            case "iPhone7,1":
                return .iPhone6Plus
            case "iPhone8,1":
                return .iPhone6s
            case "iPhone8,2":
                return .iPhone6sPlus
            case "iPhone8,4":
                return .iPhoneSE
            case "iPhone9,1", "iPhone9,3":
                return .iPhone7
            case "iPhone9,2", "iPhone9,4":
                return .iPhone7Plus
            case "iPhone10,1", "iPhone10,4":
                return .iPhone8
            case "iPhone10,2", "iPhone10,5":
                return .iPhone8Plus
            case "iPhone10,3", "iPhone10,6":
                return .iPhoneX
                
                
                /*** iPad ***/
            case "iPad1,1":
                return .iPad1
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
                return .iPad2
            case "iPad3,1", "iPad3,2", "iPad3,3":
                return .iPad3
            case "iPad3,4", "iPad3,5", "iPad3,6":
                return .iPad4
            case "iPad6,11", "iPad6,12":
                return .iPad5
            case "iPad4,1", "iPad4,2", "iPad4,3":
                return .iPadAir
            case "iPad5,3", "iPad5,4":
                return .iPadAir2
            case "iPad2,5", "iPad2,6", "iPad2,7":
                return .iPadMini
            case "iPad4,4", "iPad4,5", "iPad4,6":
                return .iPadMini2
            case "iPad4,7", "iPad4,8", "iPad4,9":
                return .iPadMini3
            case "iPad5,1", "iPad5,2":
                return .iPadMini4
            case "iPad6,7", "iPad6,8", "iPad7,1", "iPad7,2":
                return .iPadPro12_9Inch
            case "iPad7,3", "iPad7,4":
                return .iPadPro10_5Inch
            case "iPad6,3", "iPad6,4":
                return .iPadPro9_7Inch
                
                /*** Simulator ***/
//            case "i386", "x86_64":
//                return mapToDevice()
            //            return .simulator
            default:
                return mapToDevice()
            }
        }
        
        fileprivate static func mapToDevice() -> Device {
            let screenHeight = UIScreen.main.bounds.height
            if screenHeight == iPhoneSmallHeight {
                return .iPhoneSmall
            } else if screenHeight == iPhoneHeight {
                return .iPhone
            } else if screenHeight == iPhonePlusHeight {
                return .iPhonePlus
            } else {
                return .iPhoneXSimulator
            }
        }
    }
}
