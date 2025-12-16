//
//  Atomic.swift
//  Pods
//
//  Created by Tanglei on 2025/12/15.
//

import Foundation

@propertyWrapper
public class Atomic<Value> {
    
    public var projectedValue: Atomic<Value> {
        return self
    }
    
    private let queue = DispatchQueue(label: "com.tvutil.ios")

    private var value: Value
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
    
    public func mutate<R>(_ mutation: (inout Value) -> R) -> R {
        return queue.sync {
           return mutation(&value)
        }
    }
}

// MARK: - Int 自增扩展
extension Atomic where Value == Int {
    /// 自增 1，返回新值
    @discardableResult
    public func increment() -> Int {
        return mutate { value in
            value += 1
            return value
        }
    }
    
    /// 自增指定值，返回新值
    @discardableResult
    public func increment(by delta: Int) -> Int {
        return mutate { value in
            value += delta
            return value
        }
    }
    
    /// 自减 1，返回新值
    @discardableResult
    public func decrement() -> Int {
        return mutate { value in
            value -= 1
            return value
        }
    }
}

// MARK: - Bool toggle扩展
extension Atomic where Value == Bool {
    /// 反转
    @discardableResult
    public func toggle() -> Bool {
        return mutate { value in
            return !value
        }
    }
    
}
