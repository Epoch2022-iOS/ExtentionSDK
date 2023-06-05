//
//  BKRefreshHeader.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit
import MJRefresh
import Lottie

/** Lottie类型*/
enum LottieType: String {
    case `default`
    case none
}

public class BKRefreshHeader: MJRefreshStateHeader {
    
    var bgColor: UIColor? = .lightWhiteDark27
    private var first: Bool = false
    
    // MARK: Lifecycle
    public override func prepare() {
        super.prepare()
        
        self.lastUpdatedTimeLabel?.isHidden = true
        self.stateLabel?.isHidden = true
        self.mj_h = 56
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        
        self.backgroundColor = bgColor
        if lottieView.constraints.count > 0 { return }
        lottieView.frame = CGRect(x: (bounds.size.width-44)/2, y: (bounds.size.height-44)/2, width: 44, height: 44)
    }
    
    public override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        if pullingPercent <= 1 && state == .idle && !first {
            lottieView.currentProgress = pullingPercent
        }
    }
    
    public override func scrollViewPanStateDidChange(_ change: [AnyHashable : Any]?) {
        switch state {
        case .idle:
            lottieView.stop()
        case .pulling, .refreshing:
            lottieView.play()
        default:
            break
        }
        self.backgroundColor = bgColor
    }
    
    public override func beginRefreshing() {
        super.beginRefreshing()
        
        lottieView.play()
        first = true
    }
    
    public override func executeRefreshingCallback() {
        super.executeRefreshingCallback()
        first = false
    }
    
    // MARK: - lazy
    lazy var lottieView: AnimationView = {
        let gif = AnimationView(name: LottieType.default.rawValue, bundle: BKCommonTool.getCustomBundle(name: .Lottie))
        gif.isUserInteractionEnabled = false
        gif.contentMode = .scaleAspectFit
        gif.loopMode = .loop
        self.addSubview(gif)
        return gif
    }()
    
}
