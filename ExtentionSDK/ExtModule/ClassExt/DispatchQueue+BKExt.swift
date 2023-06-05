//
//  DispatchQueue+BKExt.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import Foundation

extension DispatchQueue {
    
    private static var onceTracker = [String]()
    
    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
    }
    
}
