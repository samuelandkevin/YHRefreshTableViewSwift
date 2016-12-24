//
//  YHRefreshFooterView.swift
//  YHRefreshTableViewSwift
//
//  Created by YHIOS002 on 16/12/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import Foundation
import UIKit


class YHRefreshFooterView: YHRefreshView {
    
    
    private var _originalScrollViewContentHeight:CGFloat = 0
    private var _originalScorllViewContentOffset:CGPoint = CGPoint.zero

    // MARK: - Super init
    override public init(frame: CGRect){
        super.init(frame: frame)
        
        self.textForNormalState = "上拉可以加载最新数据"
        self.stateIndicatorViewNormalTransformAngle = CGFloat(M_PI)
        self.stateIndicatorViewWillRefreshStateTransformAngle = CGFloat(0)
        self.refreshState = .normal
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.activityIndicatorView.isHidden = true
        _originalScrollViewContentHeight = (self.scrollView?.contentSize.height)!
        _originalScorllViewContentOffset = (self.scrollView?.contentOffset)!
        self.scrollViewEdgeInsets = UIEdgeInsetsMake(0, 0, self.height, 0)
        self.center = CGPoint(x:(self.scrollView?.width)! * 0.5, y:CGFloat((self.scrollView?.contentSize.height)!) + self.height * 0.5 + CGFloat((self.scrollView?.contentInset.bottom)!))
        
        self.isHidden = shouldHide()
    }
    
    private func shouldHide() -> Bool{
        if self.isEffectedByNavigationController {
            if (self.scrollView?.bounds.size.height)! - CGFloat(YHNavigationBarHeight) + (self.scrollView?.contentInset.bottom)! > self.y {
                return true
            }else {
                return false
            }
        }
        if (self.scrollView?.bounds.size.height)! + (self.scrollView?.contentInset.bottom)! > self.y {
            return true
        }else{
            return false
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath != YHRefreshViewObservingkeyPath {return}
        var y = CGFloat(0)
        if let point = change?[NSKeyValueChangeKey.newKey] {
            y = (point as! CGPoint).y
        }
        // 只有在 y>0 以及 scrollview的高度不为0 时才判断
        if y <= 0 || (self.scrollView?.bounds.size.height == 0) || self.refreshState == .refreshing {return}
        
        // 触发YHRefreshViewStateRefreshing状态
        if y < ((self.scrollView?.contentSize.height)! - (self.scrollView?.height)! + self.height + (self.scrollView?.contentInset.bottom)!) , self.refreshState == .willRefresh {
            self.refreshState = .refreshing
        }
        
        // 触发YHRefreshViewStateWillRefresh状态
        if y > (CGFloat((self.scrollView?.contentSize.height)!) - CGFloat((self.scrollView?.height)!) + self.height + CGFloat((self.scrollView?.contentInset.bottom)!)) ,  self.refreshState == .normal {
            if self.isHidden { return}
            self.refreshState = .willRefresh

        }
        
         // 如果scrollView内容有增减，重新调整refreshFooter位置
        if self.scrollView?.contentSize.height != _originalScrollViewContentHeight {
            layoutSubviews()
        }
        
        
    }
    
    override func endRefreshing() {
        
        UIView.animate(withDuration: 0.6, animations: {
            [unowned self] in
            self.scrollView?.contentInset = self.originalEdgeInsets!
            self.scrollView?.contentOffset = self._originalScorllViewContentOffset
            self.refreshState = .normal
            if self.isManuallyRefreshing {
                self.isManuallyRefreshing = false
            }
        }, completion: {
                (_ ) in
        })
    }

    
    
}

