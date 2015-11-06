//
//  TinyPixUtils.swift
//  TinyPix
//
//  Created by LAURA LUCRECIA SANCHEZ PADILLA on 16/10/15.
//  Copyright © 2015 LAURA LUCRECIA SANCHEZ PADILLA. All rights reserved.
//

import UIKit

class TinyPixUtils{
    class func getTintColorForIndex(index : Int) -> UIColor{
        var color : UIColor
        switch index{
        case 0:
            color = UIColor.redColor()
        case 1:
            color = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        case 2:
            color = UIColor.blueColor()
        default:
            color = UIColor.redColor()
        }
        
        return color
    }
}