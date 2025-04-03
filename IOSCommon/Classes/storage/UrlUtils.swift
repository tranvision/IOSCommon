//
//  UrlUtils.swift
//  IOSCommon
//
//  Created by Tanglei on 2024/9/6.
//

import Foundation

fileprivate let TAG = "UrlUtils"

public class UrlUtils {
    public class func getDocumentUrl()-> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    public class func getTmpUrl()-> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

}
