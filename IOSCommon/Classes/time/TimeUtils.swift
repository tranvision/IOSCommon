//
//  TimeUtils.swift
//  IOSCommon
//
//  Created by Tanglei on 2024/9/11.
//

import Foundation

public enum TimeUnitType: Int {
    case ms = 0
    case sec = 1
}

public class TimeUtils: NSObject {
    /// 计时器
    public static func formatCountTime(seconds: UInt64)-> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = (seconds % 3600) % 60
        
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        }
    }
    
    public static func formatCountTime(seconds: TimeInterval)-> String {
        return formatCountTime(seconds: UInt64(seconds))
    }
    
    public static func getDays(sec1: UInt64, sec2: UInt64)-> Int {
        var diff: UInt64 = 0
        if sec1 >= sec2 {
            diff = sec1 - sec2
        } else {
            diff = sec2 - sec1
        }
        
        //let diff = abs(Int(sec1 - sec2))
        let day = Int(diff / (24 * 60 * 60))
        return day
    }
    
    public static func now(unit: TimeUnitType = .sec)-> UInt64 {
        let ms = DispatchTime.now().uptimeNanoseconds / 1_000_000 // 取的是启动时间
        
        switch unit {
        case .ms: return ms
        case .sec: return UInt64(Date().timeIntervalSince1970)
        }
    }
}
