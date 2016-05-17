//
//  Walk.swift
//  StepCounter
//
//  Created by lucas fernández on 09/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    
    /** Takes the fraction of a number */
    func fraction() -> CGFloat {
        let (_, c_fractional) = modf(self)
        return c_fractional
    }
}

extension UIColor {
    convenience init(colorArray array: NSArray) {
        let r = array[0] as! CGFloat
        let g = array[1] as! CGFloat
        let b = array[2] as! CGFloat
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha:1.0)
    }
}

final class Walk: NSObject {
    let walkTitle: String
    let goal: CGFloat
    let info: String
    let imageName: String
    
    /** Takes the distance of a day and return the completions of each walk */
    func completions(distance: CGFloat) -> CGFloat {
        return distance / goal
    }
    
    /** Stores a different color for each fraction of the progress */
    static let progressColors = [UIColor(colorArray: [117, 194, 35]), UIColor(colorArray: [255, 195, 10]),
                                 UIColor(colorArray: [253, 32, 37]), UIColor(colorArray: [45, 153, 213])]
    
    /** Return a different number depending of the progress in order to select a color for the Array */
    class func progressIndex(fraction: CGFloat) -> Int {
        if fraction <= 0.25 {
            return 0
        } else if fraction <= 0.50 {
            return 1
        } else if fraction <= 0.75 {
            return 2
        } else {
            return 3
        }
    }
    
    init(walkTitle: String, goal: CGFloat, info: String, imageName: String) {
        self.walkTitle = walkTitle
        self.goal = goal
        self.info = info
        self.imageName = imageName
    }
    
    /** Converts a Walk Object into a Dictionary */
    class func convertDictToWalk(dict: [String: AnyObject]) -> Walk {
        let walkTitle = dict["title"] as! String
        let goal = dict["goal"] as! CGFloat
        let info = dict["info"] as! String
        let imageName = dict["imageName"] as! String
        return Walk(walkTitle: walkTitle, goal: goal, info: info, imageName: imageName)
    }
    
}