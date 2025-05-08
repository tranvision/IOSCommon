//
//  ThreadSafeQueue.swift
//  GLCamSwift
//
//  Created by Tanglei on 2024/9/2.
//

import Foundation

import Foundation

fileprivate class QueueNode<T>
{
    var value: T?
    var next: QueueNode?
    
    init(_ newvalue: T?) {
        self.value = newvalue
    }
    
}

public final class ThreadSafeQueue<T>
{
    typealias Element = T
    
    private var headNode: QueueNode<Element> // 只引用不存数据
    private var tailNode: QueueNode<Element>
    private let lock = NSLock()
    
    public init() {
        tailNode = QueueNode(nil)
        headNode = tailNode
    }
    
    public func enqueue(_ value: T) {
        lock.lock()
        tailNode.next = QueueNode(value)
        tailNode = tailNode.next!
        lock.unlock()
    }
    
    public func dequeue() -> T? {
        var item: T? = nil
        
        lock.lock()
        if let newhead = headNode.next {
            headNode = newhead
            item = newhead.value
            newhead.value = nil
        }
        lock.unlock()
        return item
    }
    
    public func clear() {
        lock.lock()
        tailNode = QueueNode(nil)
        headNode = tailNode
        lock.unlock()
    }
    
    public func isEmpty() -> Bool {
        var empty = false
        
        lock.lock()
        empty = (headNode === tailNode)
        lock.unlock()
        return empty
    }
}
