//
//  AsyncHelper.swift
//  IOSCommon
//
//  Created by Tanglei on 2024/9/11.
//

import Foundation

public enum DispatchType: String {
    case main = "main"
    case global = "global"
}

public class AsyncHelper: NSObject {
    public static func sleep(seconds: Double, dispType: DispatchType = .global, completion: @escaping () -> Void) {
        getDispQueue(dispType).asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }

    public static func sleep(seconds: Double, dispType: DispatchType = .global, execute: DispatchWorkItem) {
        
        getDispQueue(dispType).asyncAfter(deadline: .now() + seconds, execute: execute)
    }
    
    public static func sleep(sec: Double, dispType: DispatchType = .global) async {
        await withCheckedContinuation { contin in
            getDispQueue(dispType).asyncAfter(deadline: .now() + sec) {
                contin.resume()
            }
        }
    }
    
    private static func getDispQueue(_ dispType: DispatchType)-> DispatchQueue {
        if dispType == .main {
            return DispatchQueue.main
        } else {
            return DispatchQueue.global()
        }
    }
    
}
