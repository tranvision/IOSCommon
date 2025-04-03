//
//  File.swift
//  
//
//  Created by Tanglei on 2024/7/3.
//

import Foundation

final public class BuildConfig {
    static public let shared = BuildConfig()
    private var _isInternal = false
    private var verStr = "v0.0.1"
    
    public var isInternal: Bool { _isInternal }
    public var version: String { verStr }
    public var market: String { "iOS AppStore" }
    
    private init() {
        if let infoDict = Bundle.main.infoDictionary {
            let internalStr = infoDict["IS_INTERNAL"] as! String
            
            _isInternal = Int(internalStr) == 1
            verStr = infoDict["CFBundleShortVersionString"] as! String
        }
    }
    
}
