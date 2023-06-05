//
//  DarkModeTool.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import UIKit

class BKDarkModeTool {
    
    enum DarkModeConfig: String {
        case appTheme
    }
    
    enum Mode: String, CaseIterable {
        // 跟随系统
        case follow
        // 白天
        case light
        // 黑夜
        case dark
        
        var des: String {
            switch self {
            case .follow: return "跟随系统"
            case .light: return "浅色模式"
            case .dark: return "深色模式"
            }
        }
        
        @available(iOS 13.0, *)
        var style: UIUserInterfaceStyle {
            switch self {
            case .follow: return .unspecified
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    /// 默认跟随系统
    @UD(key: DarkModeConfig.appTheme.rawValue, defaultValue: "follow") private static var appTheme: String
    
    /// 模式
    static var mode: Mode {
        get { return Mode(rawValue: appTheme) ?? .follow }
        set { appTheme = newValue.rawValue }
    }
    
    /// 创造颜色
    static func makeColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { $0.userInterfaceStyle == .light ? light : dark }
        } else {
            return BKDarkModeTool.mode == .light ? light : dark
        }
    }
    
    /// 创造图片
    static func makeImage(light: UIImage?, dark: UIImage?) -> UIImage? {
        if #available(iOS 13.0, *) {
            guard let _light = light, let _dark = dark, let config = _light.configuration else { return light }
            let lightImage = _light.withConfiguration(config.withTraitCollection(.init(userInterfaceStyle: .light)))
            lightImage.imageAsset?.register(_dark, with: config.withTraitCollection(.init(userInterfaceStyle: .dark)))
            return lightImage.imageAsset?.image(with: .current) ?? light
        } else {
            return BKDarkModeTool.mode == .light ? light : dark
        }
    }
    
}

extension UIColor {
    
    public static func color(light: UIColor, dark: UIColor) -> UIColor {
        return BKDarkModeTool.makeColor(light: light, dark: dark)
    }
    
    public static let lightWhiteDark17 = UIColor.color(light: .white, dark: BKColorDef.dark17)
    public static let lightWhiteDark27 = UIColor.color(light: .white, dark: BKColorDef.dark27)
    public static let lightWhiteDark33 = UIColor.color(light: .white, dark: BKColorDef.dark33)
    
    public static let lightBlackDarkWhite = UIColor.color(light: .black, dark: .white)
    public static let lightBlackDarkLight139 = UIColor.color(light: BKColorDef.black51, dark: BKColorDef.light139)
    public static let lightBlack51DarkLight230 = UIColor.color(light: BKColorDef.black51, dark: BKColorDef.light230)
    public static let lightBlack51Dark27 = UIColor.color(light: BKColorDef.black51, dark: BKColorDef.dark27)
    
    public static let lightGray229Dark27 = UIColor.color(light: BKColorDef.gray229, dark: BKColorDef.dark27)
    public static let lightGray229Dark33 = UIColor.color(light: BKColorDef.gray229, dark: BKColorDef.dark33)
    
    public static let lightGray241Dark17 = UIColor.color(light: BKColorDef.gray241, dark: BKColorDef.dark17)
    public static let lightGray241Dark27 = UIColor.color(light: BKColorDef.gray241, dark: BKColorDef.dark27)
    public static let lightGray241Dark33 = UIColor.color(light: BKColorDef.gray241, dark: BKColorDef.dark33)
    
    public static let lightGray245Dark27 = UIColor.color(light: BKColorDef.gray245, dark: BKColorDef.dark27)
    
    public static let lightGray248Dark17 = UIColor.color(light: BKColorDef.gray248, dark: BKColorDef.dark17)
    public static let lightGray248Dark27 = UIColor.color(light: BKColorDef.gray248, dark: BKColorDef.dark27)
    public static let lightGray248Dark33 = UIColor.color(light: BKColorDef.gray248, dark: BKColorDef.dark33)
    
    public static let lightGray250Dark17 = UIColor.color(light: BKColorDef.gray250, dark: BKColorDef.dark17)
    public static let lightGray250Dark27 = UIColor.color(light: BKColorDef.gray250, dark: BKColorDef.dark27)
    public static let lightGray250Dark33 = UIColor.color(light: BKColorDef.gray250, dark: BKColorDef.dark33)
    
    public static let lightGreen94Dark27 = UIColor.color(light: BKColorDef.green94.withAlphaComponent(0.5), dark: BKColorDef.dark27)
    
    public static let webBgColor = UIColor.color(light: UIColor.hex("#FFFFFF"), dark: UIColor.hex("#1B1B1B"))
    public static let webLabelColor = UIColor.color(light: UIColor.hex("#333333"), dark: UIColor.hex("#E6E9EE"))
    
}

extension UIImage {
    
    public static func image(light: UIImage?, dark: UIImage?) -> UIImage? {
        return BKDarkModeTool.makeImage(light: light, dark: dark)
    }
    
    /// 解决image拉伸无法适配暗黑模式的问题
    public static func fixResizableImage() {
        let selector: Selector = #selector(resizableImage(withCapInsets:resizingMode:))
        let method = class_getInstanceMethod(self, selector)
        if method == nil {
            return
        }
        let originalImp = class_getMethodImplementation(self, selector)
        if originalImp == nil {
            return
        }
        
        guard let lightTrait = lightTrait, let darkTrait = darkTrait else { return }
        
        typealias OriginalImp = @convention(c) (UIImage, Selector, UIEdgeInsets, UIImage.ResizingMode) -> UIImage
        let originalClosure = unsafeBitCast(originalImp, to: OriginalImp.self)
        
        let newBlock: @convention(block) (UIImage, UIEdgeInsets, UIImage.ResizingMode) -> UIImage = { img, insets, resizingMode in
            let resizable: UIImage = originalClosure(img, selector, insets, resizingMode)
            let resizableInLight: UIImage? = img.imageAsset?.image(with: lightTrait)
            let resizableInDark: UIImage? = img.imageAsset?.image(with: darkTrait)
            
            if resizableInLight != nil {
                resizable.imageAsset?.register(originalClosure(resizableInLight!, selector, insets, resizingMode), with: lightTrait)
            }
            if resizableInDark != nil {
                resizable.imageAsset?.register(originalClosure(resizableInDark!, selector, insets, resizingMode), with: darkTrait)
            }
            return resizable
        }
        
        let dynamicColorCompatibleImp = imp_implementationWithBlock(newBlock)
        class_replaceMethod(self, selector, dynamicColorCompatibleImp, method_getTypeEncoding(method!))
    }
    
    private static var lightTrait: UITraitCollection? {
        var trait: UITraitCollection?
        DispatchQueue.once(token: "\(kAppBundleId).light") {
            if #available(iOS 12.0, *) {
                trait = UITraitCollection(traitsFrom: [
                    UITraitCollection(displayScale: UIScreen.main.scale),
                    UITraitCollection(userInterfaceStyle: .light)
                ])
            } else {
                // Fallback on earlier versions
            }
        }
        return trait
    }
    
    private static var darkTrait: UITraitCollection? {
        var trait: UITraitCollection?
        DispatchQueue.once(token: "\(kAppBundleId).dark") {
            if #available(iOS 12.0, *) {
                trait = UITraitCollection(traitsFrom: [
                    UITraitCollection(displayScale: UIScreen.main.scale),
                    UITraitCollection(userInterfaceStyle: .dark)
                ])
            } else {
                // Fallback on earlier versions
            }
        }
        return trait
    }
    
    struct ArrowFork {
        public static let icon_arrow_left = UIImage(named: "icon_arrow_left")
        public static let icon_arrow_right = UIImage(named: "icon_arrow_right")
        public static let icon_arrow_up = UIImage(named: "icon_arrow_up")
        public static let icon_arrow_down = UIImage(named: "icon_arrow_down")
        public static let icon_fork = UIImage(named: "icon_fork")
    }
    
    struct Chat {
        public static let icon_chat_album = UIImage(named: "icon_chat_album")
        public static let icon_chat_camera = UIImage(named: "icon_chat_camera")
        public static let icon_chat_plus = UIImage(named: "icon_chat_plus")
        public static let icon_chat_face = UIImage(named: "icon_chat_face")
        public static let icon_chat_audio = UIImage(named: "icon_chat_audio")
        public static let icon_chat_keyboard = UIImage(named: "icon_chat_keyboard")
        public static let icon_chat_canDelete = UIImage(named: "icon_chat_canDelete")
        public static let icon_chat_canNotDelete = UIImage(named: "icon_chat_canNotDelete")
    }
    
}

// MARK: - Adapter CALayer
class ThemePrivateView: UIView {

    typealias TraitCollectionCallback = () -> Void
    private var callbackList: [TraitCollectionCallback?] = []
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func traitCollectionChange(_ callback: TraitCollectionCallback?) {
        callbackList.append(callback)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                for callback in callbackList {
                    callback?()
                }
            }
        }
    }
    
}

fileprivate var ThemePrivateViewKey: UInt8 = 0

extension UIView {
    
    var themePrivateView: ThemePrivateView? {
        get { return objc_getAssociatedObject(self, &ThemePrivateViewKey) as? ThemePrivateView }
        set {
            if let newValue = newValue, themePrivateView != newValue {
                themePrivateView?.removeFromSuperview()
                newValue.isHidden = true
                self.insertSubview(newValue, at: 0)
                objc_setAssociatedObject(self, &ThemePrivateViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
}

// MARK: - 扩展UIView
extension UIView {
    
    public func bk_layerBorderColor(_ color: UIColor) {
        if #available(iOS 13.0, *) {
            if themePrivateView == nil { themePrivateView = ThemePrivateView() }
            themePrivateView?.traitCollectionChange({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.layer.borderColor = color.resolvedColor(with: strongSelf.traitCollection).cgColor
            })
            layer.borderColor = color.resolvedColor(with: traitCollection).cgColor
        } else {
            layer.borderColor = color.cgColor
        }
    }
    
    public func bk_layerShadowColor(_ color: UIColor) {
        if #available(iOS 13.0, *) {
            if themePrivateView == nil { themePrivateView = ThemePrivateView() }
            themePrivateView?.traitCollectionChange({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.layer.shadowColor = color.resolvedColor(with: strongSelf.traitCollection).cgColor
            })
            layer.shadowColor = color.resolvedColor(with: traitCollection).cgColor
        } else {
            layer.shadowColor = color.cgColor
        }
    }
    
    public func bk_layerBackgroundColor(_ color: UIColor) {
        if #available(iOS 13.0, *) {
            if themePrivateView == nil { themePrivateView = ThemePrivateView() }
            themePrivateView?.traitCollectionChange({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.layer.backgroundColor = color.resolvedColor(with: strongSelf.traitCollection).cgColor
            })
            layer.backgroundColor = color.resolvedColor(with: traitCollection).cgColor
        } else {
            layer.backgroundColor = color.cgColor
        }
    }
    
}

// MARK: - 扩展CAGradientLayer
extension CAGradientLayer {
    
    public func bk_colors(_ cs: [UIColor], with target: UIView) {
        if #available(iOS 13.0, *) {
            if target.themePrivateView == nil { target.themePrivateView = ThemePrivateView() }
            target.themePrivateView?.traitCollectionChange({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.colors = cs.map { $0.resolvedColor(with: target.traitCollection).cgColor }
            })
            colors = cs.map { $0.resolvedColor(with: target.traitCollection).cgColor }
        } else {
            colors = cs.map { $0.cgColor }
        }
    }
    
}

// MARK: - 扩展CAShapeLayer
extension CAShapeLayer {
    
    public func bk_fillColor(_ color: UIColor, with target: UIView) {
        if #available(iOS 13.0, *) {
            if target.themePrivateView == nil { target.themePrivateView = ThemePrivateView() }
            target.themePrivateView?.traitCollectionChange({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.fillColor = color.resolvedColor(with: target.traitCollection).cgColor
            })
            fillColor = color.resolvedColor(with: target.traitCollection).cgColor
        } else {
            fillColor = color.cgColor
        }
    }
    
}

// MARK: - 扩展CALayer
extension CALayer {
    
    public func bk_borderColor(_ color: UIColor, with target: UIView) {
        if #available(iOS 13.0, *) {
            if target.themePrivateView == nil { target.themePrivateView = ThemePrivateView() }
            target.themePrivateView?.traitCollectionChange({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.borderColor = color.resolvedColor(with: target.traitCollection).cgColor
            })
            borderColor = color.resolvedColor(with: target.traitCollection).cgColor
        } else {
            borderColor = color.cgColor
        }
    }
    
    public func bk_shadowColor(_ color: UIColor, with target: UIView) {
        if #available(iOS 13.0, *) {
            if target.themePrivateView == nil { target.themePrivateView = ThemePrivateView() }
            target.themePrivateView?.traitCollectionChange({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.shadowColor = color.resolvedColor(with: target.traitCollection).cgColor
            })
            shadowColor = color.resolvedColor(with: target.traitCollection).cgColor
        } else {
            shadowColor = color.cgColor
        }
    }
    
    public func bk_backgroundColor(_ color: UIColor, with target: UIView) {
        if #available(iOS 13.0, *) {
            if target.themePrivateView == nil { target.themePrivateView = ThemePrivateView() }
            target.themePrivateView?.traitCollectionChange({ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.backgroundColor = color.resolvedColor(with: target.traitCollection).cgColor
            })
            backgroundColor = color.resolvedColor(with: target.traitCollection).cgColor
        } else {
            backgroundColor = color.cgColor
        }
    }
    
}
