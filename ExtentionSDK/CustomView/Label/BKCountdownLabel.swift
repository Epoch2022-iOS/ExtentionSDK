//
//  BKCountdownLabel.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

// MARK: - UILabel数字倒计时动画
class BKCountdownLabel: UILabel {
    
    /// 开始倒计时时间
    var seconds: Int = 3
    /// 倒计时时间回调
    var onCountdownCallback: ((_ seconds: Int) -> Void)?
    // 倒计时计时器
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func start() {
        self.startTimer()
    }
    
    public func destoryTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startTimer() {
        self.destoryTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdownAction), userInfo: nil, repeats: true)
    }
    
    @objc private func countdownAction() {
        self.onCountdownCallback?(seconds)
        if seconds > 0 {
            text = String(format: "%d", seconds)
            let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            // 字体变化大小
            animation.values = [3.0, 2.0, 0.7, 1.0]
            animation.duration = 0.5
            self.layer.add(animation, forKey: "scaleTime")
            seconds -= 1
        } else {
            self.destoryTimer()
            self.removeFromSuperview()
        }
    }
    
}
