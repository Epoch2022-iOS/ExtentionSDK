//
//  UIStackView+BKEt.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import Foundation
import UIKit
import SwifterSwift

// MARK: UIStackView 扩展
extension UIStackView {
    
    enum StackShadowStyle: Int {
        case deep = 0 // default
        case shallow
        case all
        case top
        case left
        case right
        case bottom
    }
    
    func removeAllSubviews() {
        self._removeAllSubviews()
        self.removeArrangedSubviews()
    }
    
    /** UIStackView样式扩展*/
    func bk_addShadowStyle(cornerRadius: CGFloat,
                           with style: StackShadowStyle = .deep,
                           shadowColor: UIColor = .white,
                           shadowOffset: CGFloat = 2) {
        switch style {
        case .deep:
            self.bk_addStyle(cornerRadius: cornerRadius, backgroundColor: .lightWhiteDark33, shadowRadius: 3, shadowOffset: CGSize(width: 1, height: 2), shadowOpacity: 0.5, shadowColor: .white)
        case .shallow:
            self.bk_addStyle(cornerRadius: cornerRadius, backgroundColor: .lightWhiteDark33, shadowRadius: 5, shadowOffset: CGSize(width: 0, height: 2), shadowOpacity: 0.5, shadowColor: UIColor.white.withAlphaComponent(0.3))
        default:
            var offset: CGSize = .zero
            switch style {
            case .all: offset = CGSize(width: 0, height: 0)
            case .top: offset = CGSize(width: 0, height: -shadowOffset)
            case .left: offset = CGSize(width: -shadowOffset, height: 0)
            case .right: offset = CGSize(width: shadowOffset, height: 0)
            case .bottom: offset = CGSize(width: 0, height: shadowOffset)
            default: break
            }
            self.bk_addStyle(cornerRadius: cornerRadius, backgroundColor: .lightWhiteDark33, shadowRadius: 5, shadowOffset: offset, shadowOpacity: 0.5, shadowColor: shadowColor)
        }
    }
    
    /** UIStackView样式扩展*/
    func bk_addStyle(cornerRadius: CGFloat,
                     backgroundColor: UIColor = .lightWhiteDark33,
                     borderWidth: CGFloat = 0,
                     borderColor: UIColor = .clear,
                     shadowRadius: CGFloat = 0,
                     shadowOffset: CGSize = CGSize(width: 0, height: 0),
                     shadowOpacity: Float = 0,
                     shadowColor: UIColor = .clear) {
        let subView = UIView(frame: bounds)
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = cornerRadius
        subView.backgroundColor = backgroundColor
        subView.layer.borderWidth = borderWidth
        subView.bk_layerBorderColor(borderColor)
        subView.bk_layerShadowColor(shadowColor)
        subView.layer.shadowOpacity = shadowOpacity
        subView.layer.shadowOffset = shadowOffset
        subView.layer.shadowRadius = shadowRadius
        self.insertSubview(subView, at: 0)
    }
    
    // MARK: - Private
    private func _removeAllSubviews() {
        for view in arrangedSubviews {
            view.removeFromSuperview()
        }
    }
    
}
