//
//  FirebaseAnalyticsMgr.swift
//
//
//  Created by Tanglei on 2024/7/4.
//

import Foundation
//import Firebase
import FirebaseAnalytics

public class FirebaseAnalyticsMgr: NSObject {
    private override init() {}
    
    public static func event(name:String, parameters: [String: Any]?) {
        if let parameters = parameters {
            Analytics.logEvent(name, parameters: parameters)
            LogUtil.d(tag: "Analytics", "event:\(name) " + "\(parameters)")
        } else {
            Analytics.logEvent(name, parameters: nil)
            LogUtil.d(tag: "Analytics", "event:\(name) ")
        }
        
    }

}
