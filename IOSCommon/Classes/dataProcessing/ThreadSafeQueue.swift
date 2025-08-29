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

    /// 线程安全获取队列元素个数
    public func count() -> Int {
        lock.lock()
        defer { lock.unlock() }
        var node = headNode.next
        var total = 0
        while node != nil {
            total += 1
            node = node?.next
        }
        return total
    }

    /// 线程安全地删除队列尾部的最新N个元素
    /// - Parameter count: 要删除的元素数量
    /// - Returns: 实际删除的数量
    @discardableResult
    public func removeLast(_ count: Int) -> Int {
        lock.lock()
        defer { lock.unlock() }
        
        // 统计当前队列元素数量
        var node = headNode.next
        var total = 0
        while node != nil {
            total += 1
            node = node?.next
        }
        
        // 如果数量不足，直接返回0
        if count <= 0 || total < count {
            return 0
        }
        
        // 找到新的tailNode（倒数第N+1个节点）
        var prev: QueueNode<Element>? = headNode
        var steps = total - count
        for _ in 0..<steps {
            prev = prev?.next
        }
        // 断开链表
        prev?.next = nil
        tailNode = prev!
        return count
    }

}
