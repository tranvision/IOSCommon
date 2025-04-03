//
//  IOSCommon
//
//  Created by Tanglei on 2024/10/15.
//

import Foundation
import KeychainSwift

public enum StorageType: String {
    case userDefault = "userDefault"
    case keychain = "keychain"
}

public class StorageMgr: NSObject {
    public static let shared = StorageMgr()
    private var keychain = KeychainSwift()
    
    public func get<T>(forKey key: String, defVal: T? = nil, storage: StorageType = .userDefault)-> T? {
        let useUsrDefault = storage == .userDefault
        
        if T.self == Bool.self {
            if let result = useUsrDefault ? UserDefaults.standard.bool(forKey: key)
              : keychain.getBool(key) {
                return (result as! T)
            }
            
        } else if T.self == Int.self {
            if let result = useUsrDefault ? UserDefaults.standard.integer(forKey: key)
              : str2int(keychain.get(key)) {
                return (result as! T)
            }
        } else if T.self == Double.self {
            if let result = useUsrDefault ? UserDefaults.standard.double(forKey: key)
              : str2double(keychain.get(key)) {
                return (result as! T)
            }
        } else if T.self == String.self {
            if let result = useUsrDefault ? UserDefaults.standard.string(forKey: key)
              : keychain.get(key) {
                return (result as! T)
            }
        } else {
            assert(false, "not supported!")
        }
        
        return defVal
    }
    
    public func set(_ value: Any, forKey key: String, storage: StorageType = .userDefault) {
        if storage == .userDefault {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            if value is Bool {
                keychain.set(value as! Bool, forKey: key)
            } else if value is Int {
                keychain.set("\(value)", forKey: key)
            } else if value is Double {
                keychain.set("\(value)", forKey: key)
            } else if value is String {
                keychain.set(value as! String, forKey: key)
            } else {
                assert(false, "not supported!")
            }
            
        }
    }
    
    public func clear() {
        LogUtil.i(tag: "storage", "clear")
        
        keychain.clear()
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }
    }
    
    private func str2double(_ str: String?)-> Double? {
        guard let string = str else {
            return nil
        }
        if let n = Double(string) {
            return n
        }
        return nil
    }
    
    private func str2int(_ str: String?)-> Int? {
        guard let string = str else {
            return nil
        }
        if let n = Int(string) {
            return n
        }
        return nil
    }
}
