//
//  LogUtil.swift
//
//
//  Created by Tanglei on 2024/7/3.
//

import Foundation
import os

fileprivate class LogFileWrapper {
    var fileHandle: FileHandle?
    
    init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
    
    deinit {
        try? fileHandle?.close()
        fileHandle = nil
    }
}

public final class LogUtil {
    private static var fileEnabled = false
    private static var logFile: LogFileWrapper?
    private static var logFileURL: URL?
    private static var _logger: OSLog?
    private static var logger: OSLog {
        get {
            if _logger == nil {
                let bundleId = Bundle.main.bundleIdentifier!
                _logger = OSLog(subsystem: bundleId, category: "native")
            }
            return _logger!
        }
    }
    private static var internalMode: Bool {
        get {
            BuildConfig.shared.isInternal
        }
    }
    
    public static func d<T: CustomStringConvertible>(tag: String, _ objects: T...) { printArgs(.debug, "[\(tag)]💡", objects) }
    public static func i<T: CustomStringConvertible>(tag: String, _ objects: T...) { printArgs(.info, "[\(tag)]🟢", objects) }
    public static func e<T: CustomStringConvertible>(tag: String, _ objects: T...) { printArgs(.error, "[\(tag)]🔴", objects) }
    public static func w<T: CustomStringConvertible>(tag: String, _ objects: T...) { printArgs(.info, "[\(tag)]🟡", objects) }
    
    public static func enableFileLog(_ flag: Bool) {
        fileEnabled = flag
    }
    
    private static func printArgs<T: CustomStringConvertible>(_ logLevel: OSLogType, _ prefix: String, _ objects: T...) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS" // 指定日期格式为 时:分:秒.毫秒
        let time = formatter.string(from: date)
        let str = objects.map { String(describing: $0) }.joined(separator: "  ")
        let debug = prefix.firstIndex(of: "💡") != nil
        
        // 发布时 logd不输出
        if !internalMode && debug {
            return
        }
        
        let text = "\(time) \(prefix) \(str)"
        os_log(logLevel, log: logger, "%@", text)
        if fileEnabled || internalMode {
            writeToFile(text)
        }
    }
    
    private static func writeToFile(_ str: String) {
        
        if logFileURL == nil {
            let dateFmt = DateFormatter()
            dateFmt.dateFormat = "yyyyMMdd"
            let dateStr = dateFmt.string(from: Date())
            self.logFileURL = UrlUtils.getTmpUrl().appendingPathComponent("log_\(dateStr)_native.log")
        }
        
        guard let url = logFileURL else {
            print("invalid log file")
            return
        }
        
        let line = str + "\n"
        do {
            if !FileManager.default.fileExists(atPath: url.path) {
                try line.write(to: url, atomically: true, encoding: .utf8)
            } else {
                if logFile == nil {
                    let fileHandle = try FileHandle(forWritingTo: url as URL)
                    logFile = LogFileWrapper(fileHandle: fileHandle)
                }
                if let fileHandle = logFile?.fileHandle {
                    _ = fileHandle.seekToEndOfFile()
                    if let data = line.data(using: String.Encoding.utf8) {
                        fileHandle.write(data)
                        try fileHandle.synchronize()
                    }
                }
            }
        } catch {
            print("could not write to file: \(url).")
        }
    }
    
}
