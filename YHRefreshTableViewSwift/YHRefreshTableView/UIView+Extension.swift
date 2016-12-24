//
//  UIView+Extension.swift
//  YHRefreshTableViewSwift
//
//  Created by YHIOS002 on 16/12/21.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var maxX: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
    }
    
    var maxY: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
    }
    
}


