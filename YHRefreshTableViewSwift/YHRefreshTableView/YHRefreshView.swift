//
//  YHRefreshView.swift
//  YHRefreshTableViewSwift
//
//  Created by YHIOS002 on 16/12/21.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import Foundation
import UIKit

enum YHRefreshViewState{
    case willRefresh
    case refreshing
    case normal
}

enum YHRefreshViewStyle {
    case classical
    case custom
}

typealias RefreshViewOperationBlock = (_ refreshView:YHRefreshView,_ progress:CGFloat) -> Void

let YHRefreshViewMethodIOS7 = (UIDevice.current.systemVersion as NSString).floatValue
let YHRefreshViewObservingkeyPath = "contentOffset"
let YHNavigationBarHeight = 64


// ---------------------------配置----------------------------------

// 进入刷新状态时的提示文字
let YHRefreshViewRefreshingStateText  = "正在加载最新数据,请稍候"
// 进入即将刷新状态时的提示文字
let YHRefreshViewWillRefreshStateText = "松开即可加载最新数据"

let YHRefreshViewDefaultHeight = 70
let YHActivityIndicatorViewMargin = 50.0
let YHTextIndicatorMargin = 20.0
let YHTimeIndicatorMargin = 10.0

class YHRefreshView : UIView {
    
    // MARK: - private 变量
    fileprivate var _stateIndicatorView:UIImageView = UIImageView()
    fileprivate var _textIndicator:UILabel = UILabel()
    fileprivate var _timeIndicator:UILabel = UILabel()
    fileprivate var _lastRefreshingTimeString:String = ""
//        {
//        get{
//            if self._lastRefreshingTimeString.isEmpty {
//                return refreshingTimeString()
//            }
//            return self._lastRefreshingTimeString
//        }
//        set{
//            
//        }

//    }
    fileprivate var _refreshStyle:YHRefreshViewStyle = .classical
    
    // MARK: - open 变量
    var beginRefreshingOperation:(() -> Void )?
    weak var beginRefreshingTarget:AnyObject?
    var beginRefreshingAction:Selector?
    var isEffectedByNavigationController:Bool = false
    
    // 支持高度自定义操作的block，需要自定义刷新动画时使用,只需将对应操作加入对应的block即可
    var normalStateOperationBlock:RefreshViewOperationBlock? = nil {
        didSet(newValue){
            if newValue != nil {
                normalStateOperationBlock = newValue
                normalStateOperationBlock!(self, 0)
            }
        }
    }
    
    var willRefreshStateOperationBlock:RefreshViewOperationBlock?
    var refreshingStateOperationBlock:RefreshViewOperationBlock?
    
    
    // --------------------------- 以下时为此类的子类开放的接口 ---------------------------
    
    weak var scrollView:UIScrollView?
    var refreshState:YHRefreshViewState = .normal {
      
        didSet{
            switch (refreshState) {
            // 进入刷新状态
            case .refreshing:
                
                originalEdgeInsets = self.scrollView?.contentInset
                self.scrollView?.contentInset = syntheticalEdgeInsets(edgeInsets: scrollViewEdgeInsets)
                    
                activityIndicatorView.startAnimating()
                _stateIndicatorView.isHidden = true
                activityIndicatorView.isHidden = false
                _lastRefreshingTimeString =  refreshingTimeString()
                _textIndicator.text = YHRefreshViewRefreshingStateText
                    
                if refreshingStateOperationBlock != nil {
                    refreshingStateOperationBlock!(self, 1.0)
                }
                
                if beginRefreshingOperation != nil {
                        beginRefreshingOperation!()
                } else if beginRefreshingTarget != nil{
                    
                    if beginRefreshingTarget?.responds(to: beginRefreshingAction) == true {
                        
                            beginRefreshingTarget?.perform(beginRefreshingAction)
                        
                    }
                }
                break
                
            case .willRefresh:
                
                    _textIndicator.text = YHRefreshViewWillRefreshStateText
                    if willRefreshStateOperationBlock != nil {
                        willRefreshStateOperationBlock!(self, 1)
                    }
                    UIView.animate(withDuration: 0.5, animations: {
                        [unowned self] in
                        self._stateIndicatorView.transform = CGAffineTransform(rotationAngle: self.stateIndicatorViewWillRefreshStateTransformAngle)
                    }, completion: {
                        _ in
                    })
                    
                break
                
            case .normal:
                if normalStateOperationBlock != nil {
                    normalStateOperationBlock!(self, 0)
                }
                _textIndicator.text = textForNormalState;
                _stateIndicatorView.transform = CGAffineTransform(rotationAngle: stateIndicatorViewNormalTransformAngle)
                _timeIndicator.text = "最后更新：\(_lastRefreshingTimeString)"
                _stateIndicatorView.isHidden = false;
                activityIndicatorView.stopAnimating()
                activityIndicatorView.isHidden = true
                break;
            
            }
  

        }
        
    }
    var textForNormalState:String = ""
    
    // 子类自定义位置使用
    var scrollViewEdgeInsets:UIEdgeInsets = UIEdgeInsets()
    
    var stateIndicatorViewNormalTransformAngle:CGFloat = 0
    
    var  stateIndicatorViewWillRefreshStateTransformAngle:CGFloat = 0
    
    // --记录原始contentEdgeInsets
    var originalEdgeInsets:UIEdgeInsets?
    
    // --加载指示器
    var activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var isManuallyRefreshing:Bool = false
    
    
    // MARK: - init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        if _refreshStyle == .classical {
            let activity = UIActivityIndicatorView()
            activity.activityIndicatorViewStyle = .gray
            activity.startAnimating()
            self.addSubview(activity)
            self.activityIndicatorView = activity
            
            
            // 状态提示图片
            let stateIndicator = UIImageView()
            stateIndicator.image = UIImage(named: "YHRefeshView_arrow")
            self.addSubview(stateIndicator)
            _stateIndicatorView = stateIndicator
            _stateIndicatorView.bounds = CGRect.init(x:0, y:0, width:15, height:40)
            
            // 状态提示label
            let textIndicator = UILabel()
            textIndicator.bounds = CGRect.init(x:0, y:0, width:300, height:30)
            textIndicator.textAlignment = .center;
            textIndicator.backgroundColor = UIColor.clear
            textIndicator.font = UIFont.systemFont(ofSize: 14)
            textIndicator.textColor = UIColor.lightGray
            self.addSubview(textIndicator)
            _textIndicator = textIndicator
            
            // 更新时间提示label
            let timeIndicator = UILabel()
            timeIndicator.bounds = CGRect.init(x:0, y:0, width:160, height:16)
            timeIndicator.textAlignment = .center;
            timeIndicator.textColor = UIColor.lightGray
            timeIndicator.font = UIFont.systemFont(ofSize: 14)
            self.addSubview(timeIndicator)
            _timeIndicator = timeIndicator
            
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - super Life

    override func didMoveToSuperview() {
//       super.didMoveToSuperview()
       self.bounds = CGRect.init(x: 0, y: 0, width: Int((self.scrollView?.frame.size.width)!), height: Int(YHRefreshViewDefaultHeight))
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activityIndicatorView.center = CGPoint(x:CGFloat(YHActivityIndicatorViewMargin), y:self.height * 0.5);
        _stateIndicatorView.center = activityIndicatorView.center;
        
        _textIndicator.center = CGPoint(x:self.width * 0.5,y: CGFloat(activityIndicatorView.height * 0.5) + CGFloat(YHTextIndicatorMargin));
        _timeIndicator.center = CGPoint(x:self.width * 0.5,y: CGFloat(self.height) - CGFloat(_timeIndicator.height * 0.5) - CGFloat(YHTimeIndicatorMargin));
    }
    
    // 保留！
     open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
    
    deinit {
        scrollView?.removeObserver(self, forKeyPath: YHRefreshViewObservingkeyPath)
    }
 

    // MARK: - 类方法
    class func refreshView() -> YHRefreshView{
        return self.init()
    }

    class func refreshViewWithStyle(style:YHRefreshViewStyle) -> YHRefreshView{
        let refresh = self.init()
        refresh.setRefreshStyle(refreshStyle:style)
        return refresh
    }

    func setRefreshStyle(refreshStyle:YHRefreshViewStyle){
        _refreshStyle = refreshStyle;
    }
    
    
    func addToScrollView(scrollView:UIScrollView){
        
        self.scrollView = scrollView
        self.scrollView?.addSubview(self)
        self.scrollView?.addObserver(self, forKeyPath: YHRefreshViewObservingkeyPath, options: .new, context: nil)
        
        // 默认是在NavigationController控制下，否则可以调用addToScrollView:isEffectedByNavigationController:(设值为NO) 即可
        isEffectedByNavigationController = true;
    }
    
    func addToScrollView(scrollView:UIScrollView,effectedByNavigationController:Bool){
    
        addToScrollView(scrollView: scrollView)
        isEffectedByNavigationController = effectedByNavigationController;
        originalEdgeInsets = scrollView.contentInset
    }
    
    func addTarget(target:AnyObject,refreshAction:Selector){
        beginRefreshingTarget = target
        beginRefreshingAction = refreshAction
    }
    
    func endRefreshing(){
    
        UIView.animate(withDuration: 0.6, animations: {
            [unowned self] in
            self.scrollView?.contentInset = self.originalEdgeInsets!
     
        }, completion: {
         [unowned self] (_ ) in
            self.refreshState = .normal
            if self.isManuallyRefreshing {
                self.isManuallyRefreshing = false
            }
        })
        
    }
    
    
    func syntheticalEdgeInsets(edgeInsets :UIEdgeInsets)-> UIEdgeInsets{
        
        return UIEdgeInsetsMake(originalEdgeInsets!.top + edgeInsets.top, originalEdgeInsets!.left + edgeInsets.left, originalEdgeInsets!.bottom + edgeInsets.bottom, originalEdgeInsets!.right + edgeInsets.right)
    }
    
    // MARK: - Private
    // 更新时间
    private func refreshingTimeString() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
}

