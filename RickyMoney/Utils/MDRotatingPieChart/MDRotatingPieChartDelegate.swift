//
//  MDRotatingPieChartDelegate.swift
//  RickyMoney
//
//  Created by Thu Trang on 1/18/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

import UIKit

/**
 *  Delegate : all methods are optional
 */
@objc protocol MDRotatingPieChartDelegate {
    
    /**
     Triggered when a slice is going to be opened
     - parameter index: slice index in your data array
     */
    optional func willOpenSliceAtIndex(index:Int)
    
    /**
     Triggered when a slice is going to be closed
     - parameter index: slice index in your data array
     */
    optional func willCloseSliceAtIndex(index:Int)
    
    /**
     Triggered when a slice has just finished opening
     - parameter index: slice index in your data array
     */
    optional func didOpenSliceAtIndex(index:Int)
    
    /**
     Triggered when a slice has just finished closing
     - parameter index: slice index in your data array
     */
    optional func didCloseSliceAtIndex(index:Int)
}