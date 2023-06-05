//
//  BKPanGesture.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

typealias BKPanGestureHandler = (UIPanGestureRecognizer) -> Void

class BKPanGesture: UIPanGestureRecognizer {
    
    var gestureAction = BKGestureAction<UIPanGestureRecognizer>()
    
    init(config: @escaping BKPanGestureHandler) {
        super.init(target: gestureAction, action: #selector(gestureAction.gestureAction(_:)))
        config(self)
    }
    
}
