//
//  NSMutableAttributedString+BKExt.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import Foundation
import UIKit

// MARK: - NSMutableAttributedString扩展
extension NSMutableAttributedString {
    
    enum AttributedStringKeys {
        case text(String)
        case font(UIFont)
        case fontSize(CGFloat)
        case textColor(UIColor)
        case bgColor(UIColor)
        case kern(CGFloat)
        case paraStyle((CGFloat, NSTextAlignment))
    }
    
    static func string(by items: [[AttributedStringKeys]]) -> NSMutableAttributedString {
        let string = NSMutableAttributedString()
        for _items in items {
            let attributes = NSMutableDictionary()
            var str: String = ""
            for item in _items {
                switch item {
                case let .text(text):
                    str = text
                case let .font(font):
                    attributes[NSAttributedString.Key.font] = font
                case let .fontSize(fontSize):
                    attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: fontSize)
                case let .kern(kern):
                    attributes[NSAttributedString.Key.kern] = kern
                case let .textColor(textColor):
                    attributes[NSAttributedString.Key.foregroundColor] = textColor
                case let .bgColor(bgColor):
                    attributes[NSAttributedString.Key.backgroundColor] = bgColor
                case let .paraStyle((lineSpacing, align)):
                    let paraStyle = NSMutableParagraphStyle()
                    paraStyle.lineSpacing = lineSpacing
                    paraStyle.alignment = align
                    attributes[NSAttributedString.Key.paragraphStyle] = paraStyle
                }
            }
            let text = NSAttributedString(string: str, attributes: attributes as? [NSAttributedString.Key: Any])
            string.append(text)
        }
        return string
    }
    
    /// 设置在一个文本中所有特殊字符的高亮颜色
    ///
    /// - Parameters:
    ///   - allStr: 所有字符串
    ///   - highlightStr: 高亮字符
    ///   - color: 高亮颜色
    ///   - font: 高亮字体
    /// - Returns: 新字符串
    static func bk_highlight(allStr: String?,
                             highlightStr keyword: String,
                             color: UIColor = BKColorDef.green140,
                             font: UIFont = .systemFont(ofSize: 16, weight: .medium)) -> NSMutableAttributedString {
        guard let allStr = allStr, keyword.isValid else {
            return NSMutableAttributedString(string: allStr ?? "")
        }
        let str = NSMutableAttributedString(string: allStr)
        str.addAttribute(.foregroundColor, value: UIColor.lightBlack51DarkLight230, range: NSRange(location: 0, length: allStr.count))
        for i in 0...keyword.count-1 {
            var searchRange = NSMakeRange(0, allStr.count)
            let singleStr = (keyword as NSString).substring(with: NSMakeRange(i, 1))
            // 忽略大小写
            var range = (allStr as NSString).range(of: singleStr, options: .caseInsensitive, range: searchRange)
            while range.location != NSNotFound {
                // 改变多次搜索时searchRange的位置
                searchRange = NSMakeRange(NSMaxRange(range), allStr.count - NSMaxRange(range))
                str.addAttribute(.foregroundColor, value: color, range: range)
                str.addAttribute(.font, value: font, range: range)
                range = (allStr as NSString).range(of: singleStr, options: [], range: searchRange)
            }
        }
        return str
    }
    
}

extension NSMutableAttributedString {
    
    /// 添加字符串并为此段添加对应的Attribute
    @discardableResult
    func addText(_ text: String, attributes: ((_ item: AttributesItem) -> Void)? = nil) -> NSMutableAttributedString {
        let item = AttributesItem()
        attributes?(item)
        append(NSMutableAttributedString(string: text, attributes: item.attributes))
        return self
    }
    
    /// 添加Attribute作用于当前字符串
    @discardableResult
    func addAttributes(_ attributes: (_ item: AttributesItem) -> Void, range: NSRange? = nil, replace: Bool = false) -> NSMutableAttributedString {
        let item = AttributesItem()
        attributes(item)
        enumerateAttributes(in: range ?? NSRange(string.startIndex..<string.endIndex, in: string), options: .reverse) { oldAttribute, oldRange, _ in
            var newAtt = oldAttribute
            for attribute in item.attributes where replace ? true : !oldAttribute.keys.contains(attribute.key) {
                newAtt[attribute.key] = attribute.value
            }
            addAttributes(newAtt, range: oldRange)
        }
        return self
    }
    
    /// 添加图片
    @discardableResult
    func addImage(_ image: UIImage?, _ bounds: CGRect) -> NSMutableAttributedString {
        let attch = NSTextAttachment()
        attch.image = image
        attch.bounds = bounds
        append(NSAttributedString(attachment: attch))
        return self
    }
    
}
