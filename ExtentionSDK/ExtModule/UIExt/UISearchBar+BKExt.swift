//
//  UISearchBar+BKExt.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import UIKit

/**
 * 改变searchBar的frame只会影响其中搜索框的宽度,不会影响其高度,原因如下:
 *   系统searchBar中的UISearchBarTextField的高度默认固定为28
 *   左右边距固定为8,上下边距是父控件view的高度减去28除以2
 *
 * 1. 重写UISearchBar的子类(BKSearchBar),重新布局UISearchBar子控件的布局
 * 2. 增加成员属性contentInset,控制UISearchBarTextField距离父控件的边距
 * 2.1 若用户没有设置contentInset,则计算出默认的contentInset
 * 2.2 若用户设置了contentInset,则根据最新的contentInset布局UISearchBarTextField
 *
 */

class BKSearchBar: UISearchBar {
    
    var contentInset: UIEdgeInsets? {
        didSet {
            self.layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let _contentInset = contentInset {
            textField?.frame = CGRect(x: _contentInset.left, y: _contentInset.top, width: bounds.width - _contentInset.left - _contentInset.right, height: bounds.height - _contentInset.top - _contentInset.bottom)
        } else {
            let horizontal: CGFloat = 8.0
            let vertical: CGFloat = (bounds.height-28.0)/2
            contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        }
        
    }
    
}

// MARK: - UISearchBar扩展
extension UISearchBar {
    
    var cancelBtn: UIButton {
        return self.value(forKey: "cancelButton") as! UIButton
    }
    
    func setCancelBtnStyle() {
        cancelBtn.isEnabled = true
        cancelBtn.isUserInteractionEnabled = true
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.lightBlack51DarkLight230, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
}
