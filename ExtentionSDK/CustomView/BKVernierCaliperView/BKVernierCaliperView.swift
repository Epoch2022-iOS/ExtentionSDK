//
//  BKVernierCaliperView.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

class BKVernierCaliperConfigure {
    /// 文字字体
    var textFont: UIFont = .mediumPingFangSC(14)
    /// 间隔值，每两条相隔多少值
    var gap: Int = 8
    /// 长线条
    var long: CGFloat  = 40.0
    /// 短线条
    var short: CGFloat = 25.0
    /// 单位
    var unit: String = ""
    /// 最小值
    var minValue: CGFloat = 0.0
    /// 最大值
    var maxValue: CGFloat = 100.0
    /// 最小单位
    var minimumUnit: CGFloat = 1
    /// 单位间隔
    var unitInterval: Int = 10
}

class BKVernierCaliperView: UIView {
    
    private var configure: BKVernierCaliperConfigure = BKVernierCaliperConfigure()
    private var section: Int = 0
    private var limitDecimal: NSDecimalNumber = NSDecimalNumber(0)
    private var indexValue: String = "" {
        didSet {
            if indexValue != oldValue {
                indexValueCallback?(indexValue)
            }
        }
    }
    
    var indexValueCallback: ((String) -> ())?
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear // UIColor("#F7F7F7")
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BKVernierCaliperHeaderCell.self, forCellWithReuseIdentifier: "BKVernierCaliperHeaderCell")
        collectionView.register(BKVernierCaliperFooterCell.self, forCellWithReuseIdentifier: "BKVernierCaliperFooterCell")
        collectionView.register(BKVernierCaliperMiddleCell.self, forCellWithReuseIdentifier: "BKVernierCaliperMiddleCell")
        return collectionView
    }()
    
    private lazy var indexView: BKIndexView = {
        let view = BKIndexView()
        view.triangleColor = BKColorDef.green140
        view.backgroundColor = UIColor.clear
        view.lineHeight = configure.long
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.clear
        addSubview(collectionView)
        addSubview(indexView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(6)
            make.height.equalTo(self).offset(-6)
        }
        
        indexView.snp.makeConstraints { (make) in
            make.top.height.centerX.equalToSuperview()
            make.width.equalTo(12)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Private
extension BKVernierCaliperView {
    
    private func setRealValue(realValue: CGFloat, animated: Bool) {
        collectionView.setContentOffset(CGPoint.init(x: round(realValue) * CGFloat(configure.gap), y: 0), animated: animated)
    }
    
}

// MARK: - Public
extension BKVernierCaliperView {
    
    ///设置数值
    func setValue(value: CGFloat, animated: Bool){
        let x = Int(round((value - configure.minValue) / configure.minimumUnit)) * Int(configure.gap)
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(CGPoint.init(x: x, y: 0), animated: animated)
        }
    }
    
    ///更新配置
    func updateConfigure(_ configureCallback: ((BKVernierCaliperConfigure) -> Void)) {
        configureCallback(configure)
        section = Int((configure.maxValue - configure.minValue) / configure.minimumUnit) / configure.unitInterval
        collectionView.reloadData()
    }
    
    ///更新指标颜色
    func updateIndexColor(_ color: UIColor) {
        indexView.triangleColor = color
    }
    
}

extension BKVernierCaliperView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2 + self.section
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BKVernierCaliperHeaderCell", for: indexPath)
            if let cell = cell as? BKVernierCaliperHeaderCell {
                cell.backgroundColor = .clear
                cell.minValue = configure.minValue
                cell.unit = configure.unit
                cell.long = configure.long
                cell.textFont = configure.textFont
                cell.limitDecimal = NSDecimalNumber(value: Double(configure.minimumUnit))
            }
            return cell
        } else if indexPath.item == section + 1 {
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BKVernierCaliperFooterCell", for: indexPath)
            if let cell = cell as? BKVernierCaliperFooterCell {
                cell.backgroundColor = .clear
                cell.maxValue = configure.maxValue
                cell.unit = configure.unit
                cell.long = configure.long
                cell.textFont = configure.textFont
                cell.limitDecimal = NSDecimalNumber(value: Double(configure.minimumUnit))
            }
            return cell
        } else {
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BKVernierCaliperMiddleCell", for: indexPath)
            if let cell = cell as? BKVernierCaliperMiddleCell {
                cell.backgroundColor = .clear
                cell.minimumUnit = configure.minimumUnit
                cell.unit = configure.unit
                cell.unitInterval = configure.unitInterval;
                cell.minValue = configure.minimumUnit * CGFloat((indexPath.item - 1)) * CGFloat(configure.unitInterval) + configure.minValue
                cell.maxValue = configure.minimumUnit * CGFloat(indexPath.item) * CGFloat(configure.unitInterval)
                cell.textFont = configure.textFont
                cell.gap = configure.gap
                cell.long = configure.long
                cell.short = configure.short
                cell.limitDecimal = NSDecimalNumber(value: Double(configure.minimumUnit))
                cell.setNeedsDisplay()
            }
            return cell
        }
    }
    
}

extension BKVernierCaliperView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value: Int = Int(scrollView.contentOffset.x / CGFloat(configure.gap))
        var realValue: CGFloat = CGFloat(value) * configure.minimumUnit + configure.minValue
        realValue = min(max(realValue, configure.minValue), configure.maxValue)
        indexValue = NSDecimalNumber(value: Double(realValue)).stringFormatter(withExample: NSDecimalNumber(value: Double(configure.minimumUnit)))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.setRealValue(realValue: (scrollView.contentOffset.x) / CGFloat(configure.gap),  animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.setRealValue(realValue: (scrollView.contentOffset.x) / CGFloat(configure.gap),  animated: true)
    }
    
}

extension BKVernierCaliperView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == section + 1 {
            return CGSize(width: self.frame.width * 0.5, height: collectionView.frame.height)
        }
        return CGSize(width: CGFloat(configure.gap) * CGFloat(configure.unitInterval), height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
