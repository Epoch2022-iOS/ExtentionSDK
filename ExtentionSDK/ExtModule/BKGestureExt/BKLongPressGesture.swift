//
//  BKLongPressGesture.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

typealias BKLongPressGestureHandler = (UILongPressGestureRecognizer) -> Void

class BKLongPressGesture: UILongPressGestureRecognizer {
    
    var gestureAction = BKGestureAction<UILongPressGestureRecognizer>()
    
    init(config: @escaping BKLongPressGestureHandler) {
        super.init(target: gestureAction, action: #selector(gestureAction.gestureAction(_:)))
        config(self)
    }
    
}
