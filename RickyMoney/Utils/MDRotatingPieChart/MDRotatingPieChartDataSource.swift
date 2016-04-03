//
//  MDRotatingPieChartDataSource.swift
//  RickyMoney
//
//  Created by Thu Trang on 1/18/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

import UIKit

/**
 *  DataSource : all methods are mandatory to build the pie chart
 */

@objc protocol MDRotatingPieChartDataSource {
    
    /**
     Gets slice color
     - parameter index: slice index in your data array
     - returns: the color of the slice at the given index
     */
    func colorForSliceAtIndex(index:Int) -> UIColor
    
    /**
     Gets slice value
     - parameter index: slice index in your data array
     - returns: the value of the slice at the given index
     */
    func valueForSliceAtIndex(index:Int) -> CGFloat
    
    /**
     Gets slice label
     - parameter index: slice index in your data array
     - returns: the label of the slice at the given index
     */
    func labelForSliceAtIndex(index:Int) -> String
    
    /**
     Gets number of slices
     - parameter index: slice index in your data array
     - returns: the number of slices
     */
    func numberOfSlices() -> Int
}