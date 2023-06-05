//
//  BKGestureTableView.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import UIKit

protocol BKGestureTableViewDelegate: NSObjectProtocol {
    func gestureTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

// MARK: - 处理多手势的tableview
class BKGestureTableView: UITableView {
    
    weak var gestureDelegate: BKGestureTableViewDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.gestureDelegate?.gestureTableViewGestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? (gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer)
    }
    
}
