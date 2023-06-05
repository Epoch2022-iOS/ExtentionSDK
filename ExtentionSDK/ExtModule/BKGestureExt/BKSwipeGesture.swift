//
//  BKSwipeGesture.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

typealias BKSwipeGestureHandler = (UISwipeGestureRecognizer) -> Void

class BKSwipeGesture: UISwipeGestureRecognizer {
    
    var gestureAction = BKGestureAction<UISwipeGestureRecognizer>()
    
    init(config: @escaping BKSwipeGestureHandler) {
        super.init(target: gestureAction, action: #selector(gestureAction.swipeAction(_:)))
        config(self)
    }
    
}
