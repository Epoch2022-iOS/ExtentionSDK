//
//  BKTapGesture.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

typealias BKTapGestureHandler = (UITapGestureRecognizer) -> Void

class BKTapGesture: UITapGestureRecognizer {
    
    var gestureAction = BKGestureAction<UITapGestureRecognizer>()
    
    init(handler: @escaping BKTapGestureHandler) {
        gestureAction.endedHandler = handler
        super.init(target: gestureAction, action: #selector(gestureAction.tapAction(_:)))
        
    }
    
    init(config: @escaping BKTapGestureHandler) {
        super.init(target: gestureAction, action: #selector(gestureAction.tapAction(_:)))
        config(self)
    }
    
}
