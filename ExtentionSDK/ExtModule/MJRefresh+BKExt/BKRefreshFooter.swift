//
//  BKRefreshFooter.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit
import MJRefresh
import Lottie

public enum BKRefreshFooterState: Int {
    case more = 0
    case noMore
    case failure
}

public class BKRefreshFooter: MJRefreshAutoStateFooter {
    
    var footerState: BKRefreshFooterState = .more
    var bgColor: UIColor? = .clear
    
    public override var state: MJRefreshState {
        didSet {
            guard oldValue != state else { return }
            if state == .pulling || state == .refreshing {
                lottieView.isHidden = false
                lottieView.stop()
                lottieView.play()
                stateLabel?.isHidden = true
                reloadBtn.isHidden = true
                self.backgroundColor = .clear
            } else if state == .idle {
                lottieView.stop()
                lottieView.isHidden = true
                stateLabel?.isHidden = true
                reloadBtn.isHidden = true
                self.backgroundColor = .clear
            } else if state == .noMoreData {
                lottieView.stop()
                lottieView.isHidden = true
                stateLabel?.isHidden = true
                reloadBtn.isHidden = true
                if footerState == .noMore {
                    stateLabel?.isHidden = false
                }
                if footerState == .failure {
                    reloadBtn.isHidden = false
                }
                self.backgroundColor = bgColor
            }
        }
    }
    
    // MARK: Lifecycle
    public override func prepare() {
        super.prepare()
        
        self.setTitle("- 哎呀,到底了 -", for: .noMoreData)
        stateLabel?.textColor = kRGBColor(161, 170, 179)
        stateLabel?.font = .systemFont(ofSize: 13)
        
        lottieView.isHidden = true
        stateLabel?.isHidden = true
        self.mj_h = 44
        self.labelLeftInset = 20
        self.triggerAutomaticallyRefreshPercent = 1
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        
        if lottieView.constraints.count > 0 { return }
        lottieView.frame = CGRect(x: (bounds.size.width-24)/2, y: (bounds.size.height-24)/2, width: 24, height: 24)
        reloadBtn.frame = self.bounds
    }
    
    @objc private func reloadData() {
        reloadBtn.isHidden = true
        lottieView.isHidden = false
        lottieView.play()
        self.beginRefreshing()
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
    
    lazy var reloadBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("加载失败,点击重试!", for: .normal)
        btn.addTarget(self, action: #selector(reloadData), for: .touchUpInside)
        self.addSubview(btn)
        
        return btn
    }()
    
}
