//
//  CGFloat+BKExt.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import Foundation
import UIKit

// MARK: - CGFloat扩展
extension CGFloat {
    
    /// 截取小数位后多少位处理(四舍五入)
    func roundToDecimal(_ fractionDigits: Int) -> CGFloat {
        let multiplier = pow(10.0, CGFloat(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
}
