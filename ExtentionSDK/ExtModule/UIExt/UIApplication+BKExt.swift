//
//  UIApplication+BKExt.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import Foundation
import UIKit

let VisibleCtrl = UIApplication.shared.visibleCtrl()
let VisibleNaviCtrl = UIApplication.shared.visibleNaviCtrl()

// MARK: - UIApplication扩展
extension UIApplication {
    
    // 默认情况下keyWindow和delegate.window是同一个对象.但是当有系统弹窗出现的时候,keyWindow就变成了另外一个对象.
    // 建议将自定义view add到delegate.window而不是keyWindow上.
    func mainWindow() -> UIWindow? {
        return delegate?.window ?? keyWindow
    }
    
    func visibleCtrl() -> UIViewController? {
        let rootVC = self.mainWindow()?.rootViewController
        return self.getVisibleViewController(from: rootVC)
    }
    
    func visibleNaviCtrl() -> UINavigationController? {
        return self.visibleCtrl()?.navigationController
    }
    
    private func getVisibleViewController(from vc: UIViewController?) -> UIViewController? {
        if let navi = vc as? UINavigationController {
            return getVisibleViewController(from: navi.visibleViewController)
        }
        if let tabbar = vc as? UITabBarController {
            return getVisibleViewController(from: tabbar.selectedViewController)
        }
        if vc?.presentedViewController != nil {
            return getVisibleViewController(from: vc?.presentedViewController)
        } else {
            return vc
        }
    }
    
}
