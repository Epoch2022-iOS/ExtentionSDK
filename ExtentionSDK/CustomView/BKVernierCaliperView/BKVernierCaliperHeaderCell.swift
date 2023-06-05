//
//  BKVernierCaliperHeaderCell.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

class BKVernierCaliperHeaderCell: UICollectionViewCell {
    var minValue: CGFloat = 0.0
    var unit: String = ""
    var long: CGFloat = 0.0
    var textFont: UIFont = .mediumPingFangSC(14)
    var limitDecimal: NSDecimalNumber = NSDecimalNumber(0)
}

extension BKVernierCaliperHeaderCell {
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor("#999999").cgColor)
        context?.setLineWidth(1.0)
        context?.setLineCap(CGLineCap.butt)
        context?.move(to: CGPoint.init(x: rect.size.width, y: 0))
        let minString = NSDecimalNumber(value: Double(minValue)).stringFormatter(withExample: limitDecimal)
        let numberString: String = String(format: "%@%@", minString, unit)
        let attribute: Dictionary = [.font: textFont, NSAttributedString.Key.foregroundColor: UIColor("#999999")]
        let width = numberString.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions(rawValue: 0), attributes: attribute, context: nil).size.width
        numberString.draw(in: CGRect.init(x: rect.width - width * 0.5, y: rect.height - CGFloat(long) + 10, width: width, height: textFont.lineHeight), withAttributes: attribute)
        context?.addLine(to: CGPoint.init(x: rect.width, y: CGFloat(long)))
        context?.strokePath()
    }
    
}

extension UIColor {
    
    private enum ColorType {
        case RGBshort(rgb: String)
        case RGBshortAlpha(rgba: String)
        case RGB(rgb: String)
        case RGBA(rgba: String)
        
        init?(from hex: String) {
            let hexString: String = {
                if hex.hasPrefix("#") {
                    return hex.replacingOccurrences(of: "#", with: "")
                } else if hex.hasPrefix("0x") {
                    return hex.replacingOccurrences(of: "0x", with: "")
                } else {
                    return hex
                }
            }()
            switch hexString.count {
            case 3:
                self = .RGBshort(rgb: hexString)
            case 4:
                self = .RGBshortAlpha(rgba: hexString)
            case 6:
                self = .RGB(rgb: hexString)
            case 8:
                self = .RGBA(rgba: hexString)
            default:
                return nil
            }
        }
        
        var value: String {
            switch self {
            case let .RGBshort(rgb):
                return rgb
            case let .RGBshortAlpha(rgba):
                return rgba
            case let .RGB(rgb):
                return rgb
            case let .RGBA(rgba):
                return rgba
            }
        }
        
        func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
            var hexValue: UInt32 = 0
            guard Scanner(string: value).scanHexInt32(&hexValue) else {
                return nil
            }
            
            let r, g, b, a, divisor: CGFloat
            
            switch self {
            case .RGBshort:
                divisor = 15
                r = CGFloat((hexValue & 0xF00) >> 8) / divisor
                g = CGFloat((hexValue & 0x0F0) >> 4) / divisor
                b = CGFloat(hexValue & 0x00F) / divisor
                a = 1
            case .RGBshortAlpha:
                divisor = 15
                r = CGFloat((hexValue & 0xF000) >> 12) / divisor
                g = CGFloat((hexValue & 0x0F00) >> 8) / divisor
                b = CGFloat((hexValue & 0x00F0) >> 4) / divisor
                a = CGFloat(hexValue & 0x000F) / divisor
            case .RGB:
                divisor = 255
                r = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
                g = CGFloat((hexValue & 0x00FF00) >> 8) / divisor
                b = CGFloat(hexValue & 0x0000FF) / divisor
                a = 1
            case .RGBA:
                divisor = 255
                r = CGFloat((hexValue & 0xFF00_0000) >> 24) / divisor
                g = CGFloat((hexValue & 0x00FF_0000) >> 16) / divisor
                b = CGFloat((hexValue & 0x0000_FF00) >> 8) / divisor
                a = CGFloat(hexValue & 0x0000_00FF) / divisor
            }
            return (red: r, green: g, blue: b, alpha: a)
        }
    }
    
    /// 通过16进制字符串创建颜色
    convenience init(_ hex: String, alpha: CGFloat? = nil) {
        if let hexType = ColorType(from: hex), let components = hexType.components() {
            self.init(red: components.red, green: components.green, blue: components.blue, alpha: alpha ?? components.alpha)
        } else {
            self.init(white: 0, alpha: 0)
        }
    }
}

extension UIFont {
    /// PingFang-SC-Bold字体
    static func boldPingFangSC(_ size: CGFloat, scale: Bool = true) -> UIFont {
        let fontSize: CGFloat = scale ? size * BKFontManager.scaleCoefficient : size
        return UIFont(name: "HelveticaNeue-Medium", size: fontSize) ?? .boldSystemFont(ofSize: fontSize)
    }

    /// PingFang-SC-Medium字体
    static func mediumPingFangSC(_ size: CGFloat, scale: Bool = true) -> UIFont {
        let fontSize: CGFloat = scale ? size * BKFontManager.scaleCoefficient : size
        return UIFont(name: "HelveticaNeue", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }
}

class BKFontManager: NSObject {
    private override init() {
        super.init()
        let coefficient = UserDefaults.standard.integer(forKey: "BKFontSize.key.kimpl")
        if coefficient != 0 {
            self.coefficient = coefficient
        }
    }
    static let shared = BKFontManager()
    ///字体等级
    private (set) var coefficient: Int = 2
}

extension BKFontManager {
    /// 设置字体等级
    static func setFontSizeCoefficient(_ coefficient: Int) {
        shared.coefficient = coefficient
        UserDefaults.standard.setValue(coefficient, forKey: "BKFontSize.key.kimpl")
        UserDefaults.standard.synchronize()
    }
    
    /// 字体等级
    static var fontSizeCoefficient: Int {
        return shared.coefficient
    }
    
    /// 字体比例系数
    static var scaleCoefficient: CGFloat {
        return 0.075 * CGFloat(shared.coefficient - 2) + 1
    }
}
