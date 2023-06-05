//
//  BKCountingLabel.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

// MARK: - UILabel数字变化动画
class BKCountingLabel: UILabel {
    
    // 开始的数字
    public var fromNum = NSNumber(integerLiteral: 0)
    // 结束的数字
    public var toNum = NSNumber(integerLiteral: 100)
    // 字符串格式化
    public var format: String = "%d"
    // 格式化字符串闭包
    public var formatCallback: ((_ value: Double) -> String)?
    
    // 动画的持续时间
    private var duration: TimeInterval = 1.0
    // 动画开始时刻的时间
    private var startTime: CFTimeInterval = 0
    // 定时器
    private var displayLink: CADisplayLink!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bk_startCounting(from fromNum: NSNumber, toNum: NSNumber, duration: Double = 1.0) {
        self.text = fromNum.stringValue
        self.fromNum = fromNum
        self.toNum = toNum
        self.duration = duration
        startDisplayLink()
    }
    
    public func bk_stopCounting() {
        if displayLink != nil {
            displayLink.remove(from: .current, forMode: .common)
            displayLink.invalidate()
            displayLink = nil
        }
    }
    
    private func startDisplayLink() {
        if displayLink != nil {
            displayLink.remove(from: .current, forMode: .common)
            displayLink.invalidate()
            displayLink = nil
        }
        displayLink = CADisplayLink(target: self, selector: .handleDisplayLink)
        // 记录动画开始时刻的时间
        startTime = CACurrentMediaTime()
        displayLink.add(to: .current, forMode: .common)
    }
    
    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        if displayLink.timestamp - startTime >= duration {
            if formatCallback != nil {
                self.text = self.formatCallback!(toNum.doubleValue)
            } else {
                self.text = String(format: self.format, toNum.doubleValue)
            }
            // 结束定时器
            bk_stopCounting()
        } else {
            // 计算现在时刻的数字
            let currentNum = (toNum.doubleValue - fromNum.doubleValue) * (displayLink.timestamp - startTime) / duration + fromNum.doubleValue
            if formatCallback != nil {
                self.text = self.formatCallback!(currentNum)
            } else {
                self.text = String(format: self.format, currentNum)
            }
        }
    }
    
}

private extension Selector {
    static let handleDisplayLink = #selector(BKCountingLabel.handleDisplayLink(_:))
}
