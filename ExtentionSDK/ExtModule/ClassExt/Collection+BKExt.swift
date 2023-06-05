//
//  Collection+BKExt.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import Foundation

extension Collection {
    
    subscript(safe index: Self.Index) -> Iterator.Element? {
        (startIndex..<endIndex).contains(index) ? self[index] : nil
    }
    
}
