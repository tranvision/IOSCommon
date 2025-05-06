//
//  NetPermCheck.swift
//  Pods
//
//  Created by Tanglei on 2025/4/30.
//

import LLNetworkAccessibility_Swift

public class NetPermCheck {
    public static func check() async-> LLNetworkAccessibility.AuthState {
        await withCheckedContinuation { contin in
            
            DispatchQueue.main.async {
                LLNetworkAccessibility.start()
                LLNetworkAccessibility.configAlertStyle(type: .custom, closeEnable: false,tintColor: .red)
                
                // 网络授权监听
                LLNetworkAccessibility.reachabilityUpdateCallBack = { state in
                    guard let state = state else { return }
                    switch state {
                    case .available: // 网络已授权
                        //print("网络已授权")
                        LLNetworkAccessibility.stop()
                        contin.resume(returning: .available)
                    case .restricted: // 网络没授权
                        //print("网络没授权")
                        LLNetworkAccessibility.stop()
                        contin.resume(returning: .restricted)
                    case .unknown: // 没有网络（飞行模式）
                        //print("没有网络（飞行模式）")
                        LLNetworkAccessibility.stop()
                        contin.resume(returning: .unknown)
                    default:
                        break
                    }
                    
                } // callback
            } // main

        }
    }
    
}
