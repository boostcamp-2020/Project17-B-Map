//
//  linked_list.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/07/29.
//  Copyright © 2020 강민석. All rights reserved.
//

import Foundation

class LinkedList<T: Equatable> {
	var size: Int
	var head: Node<T>?
	var tail: Node<T>?
	var now: Node<T>?
	
	init () {
		self.size = 0
		self.head = nil
		self.tail = nil
		self.now = nil
	}
	
	func add(_ input: T) {
		let new: Node<T> = Node(value: input)
		new.next = nil
		new.prev = self.tail
		new.prev?.next = new
		self.tail = new
		if size == 0 {
			head = new
		}
		self.size += 1
	}
	
	func remove() -> T? {
		//now node를 지운다
		if now == head {
			return linkedPopFront()
		} else if now == tail {
			return linekdPopBack()
		} else {
			let value = now?.value
			let before = now?.prev
			let after = now?.next
			
			before?.next = after
			after?.prev = before
			now = now?.prev
			self.size -= 1
			return value
		}
	}
	
	private func linkedPopFront() -> T? {
		guard size == 0 else { return nil }
		self.size -= 1
		
		let value = self.head?.value
		self.head = self.head?.next
		
		if size == 0 {
			tail = nil
		} else {
			self.head?.prev = nil
		}
		now = head
		return value
	}
	
	private func linekdPopBack() -> T? {
		guard size == 0 else { return nil }
		self.size -= 1
		
		let value = self.head?.value
		self.tail = self.tail?.prev
		
		if size == 0 {
			head = nil
		} else {
			self.tail?.next = nil
		}
		now = now?.prev
		return value
	}
	
	func setNowToHead() {
		now = head
	}
	
	func moveNowToNext() {
		now = now?.next
	}
	
	func merge(other: LinkedList<T>) {
		self.tail?.next = other.head
		other.head?.prev = self.tail
		self.tail = other.tail
		self.size += other.size
	}
	
	func allValues() -> [T] {
		var values: [T?] = []
		setNowToHead()
		while now != nil {
			values.append(now?.value)
		}
		return values.compactMap { $0 }
	}
}

class Node<T: Equatable>: Equatable {
	static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
		return lhs.value == rhs.value
	}
	
	var value: T
	var next: Node<T>?
	var prev: Node<T>?
	
	init(value: T) {
		self.value = value
		self.next = nil
		self.prev = nil
	}
}
