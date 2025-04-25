//
//  AVMetadataTool.swift
//  Pods
//
//  Created by Tanglei on 2025/4/24.
//

import AVFoundation

fileprivate let TAG = "AVMetadataTool"

public class AVMetadataTool {
    static public func extract(from audioPath: String)-> [String: Any] {
        if !FileManager.default.fileExists(atPath: audioPath) {
            LogUtil.e(tag: TAG, "not found: \(audioPath)")
            return [:]
        }
        
        let audioURL = URL(fileURLWithPath: audioPath)
        let asset = AVAsset(url: audioURL)
        var dict: [String: Any] = [:]
        
        for format in asset.availableMetadataFormats {
            for metadataItem in asset.metadata(forFormat: format) {
                if let commonKey = metadataItem.commonKey, let value = metadataItem.value {
                    dict[commonKey.rawValue] = value
                }
            }
        }
        
        let duration = CMTimeGetSeconds(asset.duration)
        dict["duration"] = duration
        return dict
    }
    
    static func write(metadata: [String: Any], to audioPath: String)-> Bool {
        /// 未实现
        assert(false, "not implemented!")
        return false
    }
    
}
