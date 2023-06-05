//
//  BKIndexView.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

class BKIndexView: UIView {
    
    var triangleColor: UIColor? {
        didSet {
            shapeLayer.fillColor = triangleColor?.cgColor
            shapeLayer.strokeColor = triangleColor?.cgColor
        }
    }
    
    var lineHeight: CGFloat = 0.0
    
    private lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private lazy var path: UIBezierPath = {
        let path = UIBezierPath()
        return path
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BKIndexView {
    
    override func draw(_ rect: CGRect) {
        path.removeAllPoints()
        path.move(to: CGPoint.init(x: 0, y: 0))
        path.addLine(to: CGPoint.init(x: bounds.width, y: 0))
        path.addLine(to: CGPoint.init(x: bounds.width * 0.5, y: bounds.width * 0.5))
        path.addLine(to: CGPoint.init(x: 0, y: 0))
        path.move(to: CGPoint.init(x: bounds.width * 0.5, y: bounds.width * 0.5))
        path.addLine(to: CGPoint.init(x: bounds.width * 0.5, y: lineHeight + bounds.width * 0.5))
        path.close()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 2
        shapeLayer.frame = bounds
    }
    
}
