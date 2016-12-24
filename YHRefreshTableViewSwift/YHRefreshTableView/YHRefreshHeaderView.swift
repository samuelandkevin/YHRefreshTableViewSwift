//
//  YHRefreshHeaderView.swift
//  YHRefreshTableViewSwift
//
//  Created by YHIOS002 on 16/12/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import Foundation
import UIKit

class YHRefreshHeaderView: YHRefreshView {
    
    private var _hasLayoutedForManuallyRefreshing:Bool = false
    
    // MARK: - Super init
    override public init(frame: CGRect){
        super.init(frame: frame)
        
        self.textForNormalState = "下拉可以加载最新数据"
        self.stateIndicatorViewNormalTransformAngle = 0
        self.stateIndicatorViewWillRefreshStateTransformAngle = CGFloat(M_PI)
        self.refreshState = .normal

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.scrollViewEdgeInsets = UIEdgeInsets(top: self.frame.size.height, left: 0, bottom: 0, right: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.center = CGPoint(x: (self.scrollView?.width)! * 0.5, y: CGFloat(-(self.height * 0.5)))
        
        // 模拟手动刷新
        if self.isManuallyRefreshing , _hasLayoutedForManuallyRefreshing == false , (Double((self.scrollView?.contentInset.top)!) > 0.0) == true {
            self.activityIndicatorView.isHidden = false
            
            // 模拟下拉操作7
            if var temp = self.scrollView?.contentOffset {
                temp.y -= self.height * 2
                self.scrollView?.contentOffset = temp // 触发准备刷新
                temp.y += self.height
                self.scrollView?.contentOffset = temp // 触发刷新
                
                _hasLayoutedForManuallyRefreshing = true
            }
        }else{
        
            self.activityIndicatorView.isHidden = !self.isManuallyRefreshing
        }
    
    }

    
    func beginRefreshing() {
        self.isManuallyRefreshing = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
        if keyPath != YHRefreshViewObservingkeyPath {return}
        var y = CGFloat(0)
        if let point = change?[NSKeyValueChangeKey.newKey] {
           y = (point as! CGPoint).y
        }
        let criticalY = -self.height - (self.scrollView?.contentInset.top)!
       
        // 只有在 y<=0 以及 scrollview的高度不为0 时才判断
        if y > 0 || (self.scrollView?.bounds.size.height == 0)  || self.refreshState == .refreshing {return}
        
        // 触发YHRefreshViewStateRefreshing状态
        if y >= criticalY , self.refreshState == .willRefresh , self.scrollView?.isDragging == false {
            self.refreshState = .refreshing
        }
        
        // 触发YHRefreshViewStateWillRefresh状态
        if y < criticalY , self.refreshState == .normal {
            self.refreshState = .willRefresh
        }else if y >= criticalY , (self.scrollView?.isDragging)! {
            self.refreshState = .normal
        }
        
        if self.refreshState == .normal ,(self.scrollView?.isDragging)! {
            let scale = (-y - (self.scrollView?.contentInset.top)!) / self.height
            if normalStateOperationBlock != nil {
                normalStateOperationBlock!(self,scale)
            }
        }
        

    }
    
}
