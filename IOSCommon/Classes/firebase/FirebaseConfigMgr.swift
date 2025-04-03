//
//  FirebaseConfigMgr.swift
//
//
//  Created by Tanglei on 2024/6/28.
//
import Foundation
import UIKit
import FirebaseRemoteConfig
import Foundation
import FirebaseCore

fileprivate let TAG = "FirebaseConfigMgr"

public final class FirebaseConfigMgr: NSObject {
    static public let shared = FirebaseConfigMgr()
    private let tag: String = "FirebaseConfigMgr"
    private var config: RemoteConfig?
    
    typealias FetchListenerType = (Bool)-> Void
    //private var fetchListeners: [FetchListenerType] = []
    private var updateListeners: [()-> Void] = []
    private var defaultConfig: [String: NSObject]?
    private var internalConfig: [String: Any]?
    private var initFlag = false
    
    /// 手动获取时的listener
//    public func addFetchListener(listener: @escaping (Bool)-> Void) {
//        self.fetchListeners.append(listener)
//    }
    
    /// 更新listener
    public func addUpdateListener(listener: @escaping ()-> Void) {
        self.updateListeners.append(listener)
    }
    
    public func removeAllListeners() {
        //self.fetchListeners = []
        self.updateListeners = []
    }
        
    private func checkEnv()-> Bool {
        if self.defaultConfig == nil {
            return false
        }
        if !BuildConfig.shared.isInternal && self.config == nil {
            return false
        }
        return true
    }
    
    /// firebase取出的配置是否包含指定key
    public func contains(key: String)-> Bool {
        if !self.checkEnv() {
            return false
        }
        
        if (BuildConfig.shared.isInternal) {
            return self.internalConfig?[key] != nil
        }
        
        let result = config!.allKeys(from: .remote).contains(key)
        return result
    }
    
    public func getBool(key: String)-> Bool {
        if !self.checkEnv() {
            return false
        }
        
        if (BuildConfig.shared.isInternal) {
            if let v = self.internalConfig?[key] {
                return v as! Bool
            }
            return self.defaultConfig![key] as! Bool
        }
        
        return config!.configValue(forKey: key).boolValue
    }
    
    public func getString(key: String)-> String {
        if !self.checkEnv() {
            return ""
        }
        
        if (BuildConfig.shared.isInternal) {
            if let v = self.internalConfig?[key] {
                return v as! String
            }
            return self.defaultConfig![key] as! String
        }
        
        return config!.configValue(forKey: key).stringValue
    }
    
    /// 获取json格式内容, 包括不限于json array, json object等
    public func getJson<T>(key: String, type: T.Type)-> T? where T : Decodable {
        if !self.checkEnv() {
            return nil
        }
        
        let str = getString(key: key)
        do {
            let result = try JSONDecoder().decode(type, from: str.data(using: .utf8)!)
            return result
        } catch {
            LogUtil.w(tag: tag, "getJson failed! string content:", str)
        }
        return nil
    }
    
    public func getInt(key: String)-> Int {
        if !self.checkEnv() {
            return -1
        }
        
        return getNumber(key: key) as! Int
    }
    
    public func getDouble(key: String)-> Double {
        if !self.checkEnv() {
            return 0.0
        }
        
        return getNumber(key: key) as! Double
    }
    
    public func getNumber(key: String)-> NSNumber {
        if !self.checkEnv() {
            return 0
        }
        
        if (BuildConfig.shared.isInternal) {
            if let v = self.internalConfig?[key] {
                //return NumberFormatter().number(from: v)!
                return anyToNSNumber(v)
            }
            return self.defaultConfig![key] as! NSNumber
        }
        
        return config!.configValue(forKey: key).numberValue
    }
    
    public func setup(defCfgFileName: String)-> Bool {
        
        let url = URL(fileURLWithPath: defCfgFileName)
        let cfgBaseName = url.deletingPathExtension().lastPathComponent
        if let path = Bundle.main.path(forResource: cfgBaseName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: fileUrl)
                let content = try JSONDecoder().decode([String: NSObjectDecodable].self, from: data)
                let dict = content.mapValues { $0.value }
                return self.setup(defaultConfig: dict)
            } catch {
                LogUtil.e(tag: TAG, "Error reading file: \(error)")
            }
        } else {
            LogUtil.e(tag: TAG, "File(\(defCfgFileName) not found in main bundle.")
        }
        return false
    }
    
    public func setup(defaultConfig: [String: NSObject])-> Bool {
        guard config == nil else {
            LogUtil.e(tag: self.tag, "setup more than twice!")
            return false
        }
        
        self.defaultConfig = defaultConfig
        let fbRef = FirebaseApp.app()
        if !BuildConfig.shared.isInternal && fbRef == nil {
            FirebaseApp.configure()
        }
        
        guard let app = FirebaseApp.app() else {
            self.initFlag = BuildConfig.shared.isInternal
            return BuildConfig.shared.isInternal
        }
        config = RemoteConfig.remoteConfig(app: app)
        
        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0
        setting.fetchTimeout = 5
        config?.configSettings = setting
        config?.setDefaults(defaultConfig)
        
        config?.addOnConfigUpdateListener {[weak self] _, err in
            guard self != nil else { return }
            for fn in self!.updateListeners {
                fn()
            }
        }
                
        self.initFlag = true
        return true
    }
    
    public func request(callback: @escaping (Bool)-> Void) {
        if !initFlag {
            callback(false)
            return
        }
        
        // internal不走firebase
        if (BuildConfig.shared.isInternal) {
            loadInternalLocalCfg()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                callback(true)
            }
            return
        }
        
        /// activate的目的就是把firebase本身的缓存更新成和fetch结果一样的最新值
        config?.fetchAndActivate { [weak self] status, error in
            guard self != nil else { return }
            
            guard status != .error else {
                LogUtil.e(tag: self!.tag, "load rconfig error", error?.localizedDescription ?? "")
                callback(false)
                return
            }
            
            LogUtil.d(tag: self!.tag, "fetchAndActivate OK")
            callback(true)
            
        }
    }
    
    public func request() async-> Bool {
        await withCheckedContinuation {[weak self] contin in
            self?.request {
                contin.resume(returning: $0)
            }
        }
    }
    
    private func loadInternalLocalCfg() {
        if let filePath = Bundle.main.path(forResource: "local_firebase_cfg", ofType: ".json") {
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                //internalConfig = try JSONDecoder().decode([String: InternalCfgType].self, from: fileContents.data(using: .utf8)!)
                if let jsonData = fileContents.data(using: .utf8) {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        internalConfig = json
                    }
                }
            } catch {
                LogUtil.w(tag: tag, "loadInternalLocalCfg failed")
            }
            
        }
        
    }
    
    private func anyToNSNumber(_ value: Any)-> NSNumber {
        if let n = value as? Int {
            return NSNumber(value: n)
        } else if let db = value as? Double {
            return NSNumber(value: db)
        } else {
            LogUtil.w(tag: tag, "failed to call anyToNSNumber")
            print(value)
            return NSNumber(value: -1)
        }
    }
    

}

