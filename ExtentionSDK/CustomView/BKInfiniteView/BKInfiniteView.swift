//
//  BKInfiniteView.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit
import SnapKit

protocol BKInfiniteViewDataSource: NSObject {
    func numberOfItems(in infiniteView: BKInfiniteView) -> Int
    func infiniteView(_ infiniteView: BKInfiniteView, cellForItemAt indexPath: IndexPath, index: Int) -> UICollectionViewCell
}

protocol BKInfiniteViewDelegate: NSObject {
    func infiniteView(_ infiniteView: BKInfiniteView, didSelectCellAt index: Int)
}

class BKInfiniteView: UIView {
    
    weak var dataSource: BKInfiniteViewDataSource?
    weak var delegate: BKInfiniteViewDelegate?
    
    private (set) var collectionView: UICollectionView!
    
    private var isHorizontalScroll: Bool {
        return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .horizontal
    }
    
    private var indexOffset: Int = 0
    
    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Public
extension BKInfiniteView {
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        collectionView.register(T.self, forCellWithReuseIdentifier: String(describing: name))
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionViewCell for \(String(describing: name)), make sure the cell is registered with collection view")
        }
        return cell
    }
    
}

// MARK: - Public
extension BKInfiniteView {
    
    func scrollToLeftItem() {
        guard isHorizontalScroll, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let centerOffsetX = collectionView.contentOffset.x - (layout.itemSize.width + layout.minimumLineSpacing)
        collectionView.setContentOffset(CGPoint(x: centerOffsetX, y: 0), animated: true)
    }
    
    func scrollToRightItem() {
        guard isHorizontalScroll, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let centerOffsetX = collectionView.contentOffset.x + (layout.itemSize.width + layout.minimumLineSpacing)
        collectionView.setContentOffset(CGPoint(x: centerOffsetX, y: 0), animated: true)
    }
    
    func scrollToTopItem() {
        guard !isHorizontalScroll, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let centerOffsetY = collectionView.contentOffset.y + (layout.itemSize.height + layout.minimumLineSpacing)
        collectionView.setContentOffset(CGPoint(x: 0, y: centerOffsetY), animated: true)
    }
    
    func scrollToBottomItem() {
        guard !isHorizontalScroll, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let centerOffsetY = collectionView.contentOffset.y - (layout.itemSize.height + layout.minimumLineSpacing)
        collectionView.setContentOffset(CGPoint(x: 0, y: centerOffsetY), animated: true)
    }
    
}

// MARK: - Private
extension BKInfiniteView {
    
    private func centreIfNeeded() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let currentOffset = collectionView.contentOffset
        let contentWidth = getTotalContentWidth()
        let centerOffsetX: CGFloat = (3 * contentWidth - bounds.size.width) * 0.5
        let distFromCentre = centerOffsetX - currentOffset.x
        if abs(distFromCentre) > (contentWidth * 0.25) {
            let cellcount = distFromCentre / (layout.itemSize.width + layout.minimumLineSpacing)
            let shiftCells = Int((cellcount > 0) ? floor(cellcount) : ceil(cellcount))
            let offsetCorrection = abs(cellcount).truncatingRemainder(dividingBy: 1) * (layout.itemSize.width + layout.minimumLineSpacing)
            if collectionView.contentOffset.x < centerOffsetX {
                collectionView.contentOffset = CGPoint(x: centerOffsetX - offsetCorrection, y: currentOffset.y)
            } else if collectionView.contentOffset.x > centerOffsetX {
                collectionView.contentOffset = CGPoint(x: centerOffsetX + offsetCorrection, y: currentOffset.y)
            }
            shiftContentArray(getCorrectedIndex(shiftCells))
            collectionView.reloadData()
        }
    }
    
    private func centreVerticallyIfNeeded() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let currentOffset = collectionView.contentOffset
        let contentHeight = getTotalContentHeight()
        let centerOffsetY: CGFloat = (3 * contentHeight  - bounds.size.height) * 0.5
        let distFromCentre = centerOffsetY - currentOffset.y
        if abs(distFromCentre) > (contentHeight * 0.25) {
            let cellcount = distFromCentre / (layout.itemSize.height + layout.minimumLineSpacing)
            let shiftCells = Int((cellcount > 0) ? floor(cellcount) : ceil(cellcount))
            let offsetCorrection = abs(cellcount).truncatingRemainder(dividingBy: 1) * (layout.itemSize.height + layout.minimumLineSpacing)
            if collectionView.contentOffset.y < centerOffsetY {
                collectionView.contentOffset = CGPoint(x: currentOffset.x, y: centerOffsetY - offsetCorrection)
            } else if collectionView.contentOffset.y > centerOffsetY {
                collectionView.contentOffset = CGPoint(x: currentOffset.x, y: centerOffsetY + offsetCorrection)
            }
            shiftContentArray(getCorrectedIndex(shiftCells))
            collectionView.reloadData()
        }
    }
    
    private func shiftContentArray(_ offset: Int) {
        indexOffset += offset
    }
    
    private func getTotalContentWidth() -> CGFloat {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let numberOfCells = dataSource?.numberOfItems(in: self) else { return 0 }
        return CGFloat(numberOfCells) * (layout.itemSize.width + layout.minimumLineSpacing)
    }
    
    private func getTotalContentHeight() -> CGFloat {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let numberOfCells = dataSource?.numberOfItems(in: self) else { return 0 }
        return (CGFloat(numberOfCells) * (layout.itemSize.height + layout.minimumLineSpacing))
    }
    
    private func getCorrectedIndex(_ indexToCorrect: Int) -> Int {
        guard let numberOfCells = dataSource?.numberOfItems(in: self), numberOfCells != 0 else { return 0 }
        if (indexToCorrect < numberOfCells && indexToCorrect >= 0) {
            return indexToCorrect
        } else {
            let countInIndex = Float(indexToCorrect) / Float(numberOfCells)
            let flooredValue = Int(floor(countInIndex))
            let offset = numberOfCells * flooredValue
            return indexToCorrect - offset
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension BKInfiniteView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource!.infiniteView(self, cellForItemAt: indexPath, index: getCorrectedIndex(indexPath.row - indexOffset))
    }
    
}

// MARK: - UICollectionViewDelegate
extension BKInfiniteView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.infiniteView(self, didSelectCellAt: getCorrectedIndex(indexPath.row - indexOffset))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isHorizontalScroll ? centreIfNeeded() : centreVerticallyIfNeeded()
    }
    
}
