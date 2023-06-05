//
//  UIScrollView+BKExt.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import Foundation
import MJRefresh

// MARK: - UIScrollView关联属性刷新扩展
extension UIScrollView {
    
    private struct AssociatedMJRefreshKeys {
        static var associatedObjectBKHeader = 0
        static var associatedObjectBKFooter = 1
    }
    
    public var bkHeader: BKRefreshHeader? {
        get { objc_getAssociatedObject(self, &AssociatedMJRefreshKeys.associatedObjectBKHeader) as? BKRefreshHeader }
        set { objc_setAssociatedObject(self, &AssociatedMJRefreshKeys.associatedObjectBKHeader, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public var bkFooter: BKRefreshFooter? {
        get { objc_getAssociatedObject(self, &AssociatedMJRefreshKeys.associatedObjectBKFooter) as? BKRefreshFooter }
        set { objc_setAssociatedObject(self, &AssociatedMJRefreshKeys.associatedObjectBKFooter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 添加下拉刷新
    ///
    /// - Parameters:
    ///   - refreshHeader: BKRefreshHeader
    ///   - refreshBlock: 刷新数据Block
    /// - Returns: UIScrollView
    @discardableResult
    final public func bk_addRefreshHeader(refreshHeader: BKRefreshHeader? = BKRefreshHeader(),
                                          bgColor: UIColor = .clear,
                                          refreshBlock: @escaping () -> Void) -> UIScrollView {
        if bkHeader != refreshHeader {
            bkHeader?.removeFromSuperview()
            if let header = refreshHeader {
                header.refreshingBlock = refreshBlock
                self.insertSubview(header, at: 0)
                bkHeader = header
                bkHeader?.bgColor = bgColor
            }
        }
        return self
    }
    
    /// 添加上拉加载
    ///
    /// - Parameters:
    ///   - loadMoreFooter: BKRefreshFooter
    ///   - loadMoreBlock: 加载更多数据Block
    /// - Returns: UIScrollView
    @discardableResult
    final public func bk_addLoadMoreFooter(loadMoreFooter: BKRefreshFooter? = BKRefreshFooter(),
                                           loadMoreBlock: @escaping () -> Void) -> UIScrollView {
        if bkFooter != loadMoreFooter {
            bkFooter?.removeFromSuperview()
            if let footer = loadMoreFooter {
                footer.refreshingBlock = loadMoreBlock
                self.insertSubview(footer, at: 0)
                bkFooter = footer
            }
        }
        return self
    }
    
    /// 触发头部下拉刷新
    final public func bk_refreshing() {
        bkHeader?.beginRefreshing()
    }
    
    /// 0.7s延迟触发头部下拉刷新
    final public func bk_delayRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.bk_refreshing()
        }
    }
    
    /// 自动判断上拉或下拉结束正在刷新状态
    final public func bk_endMJRefresh() {
        if bkHeader?.isRefreshing == true {
            bkHeader?.endRefreshing()
        }
        
        if bkFooter?.isRefreshing == true {
            bkFooter?.endRefreshing()
        }
    }
    
    /// 重置没有更多的数据
    public func bk_resetNoMoreData() {
        bkFooter?.resetNoMoreData()
    }
    
    /// 提示没有更多的数据
    public func bk_endRefreshingWithNoMoreData() {
        self.bk_endLoading(with: .noMore)
    }
    
    public func bk_endLoading(with state: BKRefreshFooterState) {
        bkFooter?.footerState = state
        switch state {
        case .more: bkFooter?.endRefreshing()
        default: bkFooter?.endRefreshingWithNoMoreData()
        }
    }
    
    public func bk_setFooterBgColor(_ color: UIColor) {
        bkFooter?.bgColor = color
    }
    
}
