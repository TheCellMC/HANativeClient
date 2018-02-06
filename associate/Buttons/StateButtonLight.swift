//
//  StateButtonLight.swift
//  associate
//
//  Created by Roey Benamotz on 1/28/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class StateButtonLight : StateButtonBase {
    
    let brightnessHeight = CGFloat(6)
    let brightnessBarWidth = CGFloat(3)
    
    override func iconName() -> String? {
        return "bulb-" + entityState!.state + ".png"
    }
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        drawBrightness(rect)
//    }
    
    override func drawAdditionalInfo(_ rect: CGRect) {
        var brightnessPercent = Float(0.0)
        if (entityState!.brightness != nil) {
            brightnessPercent = entityState!.brightness! / 255.0
        }
        if (brightnessPercent == Float(0.0)) {
            return
        }
        let actualWidth = rect.width
        
        let x0 = actualWidth * CGFloat(brightnessPercent)
        let y = rect.minY + (rect.height - brightnessHeight) / 2
        for x in stride(from: 0, to: actualWidth, by: brightnessBarWidth + 1) {
            let w = min(brightnessBarWidth, actualWidth - x)
            let r = CGRect(x: paddingX + x, y: y, width: w, height: brightnessHeight)
            let b = UIBezierPath(rect: r)
            UIColor.lightGray.set()
            if (x<x0) {
                UIColor.blue.set()
            }
            b.fill()
        }
    }

}
