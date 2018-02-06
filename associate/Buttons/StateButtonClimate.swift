//
//  StateButtonClimate.swift
//  associate
//
//  Created by Roey Benamotz on 1/28/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import Foundation
import UIKit

class StateButtonClimate : StateButtonBase {
    let brightnessHeight = CGFloat(5)
//    let brightnessFont = UIFont(name: "GeezaPro", size: 10)
    let tempertueFont = UIFont(name: "DIN Condensed", size: 12)
    private var hvacStatus : String?

    override func isActionble() -> Bool {
        return false
    }

    


    override func iconName() -> String? {
        if (entityState == nil) {
            return nil
        }
        if (self.hvacStatus == "heating") {
            return "thermostat-heat.png"
        } else if (self.hvacStatus == "cooling") {
            return "thermostat-cool.png"
        }
        return "thermostat-off.png"
    }
    
    override var entityState: HomeAssistantState? {
        didSet {
            let index = entityState!.entityId.index(of: ".")!
            let p = "sensor" + entityState!.entityId[index...] + "_thermostat_hvac_state"
            let temp = HomeAssistantDao.shared.allStates[p]
            if (temp == nil) {
                self.hvacStatus = nil
                return
            }
            self.hvacStatus = temp!.state
        }
    }
    
    override func additionalInfo() -> String? {
        if (entityState!.currentTemperature == nil) {
            return nil
        }
        return String(format: "Current: %.1f",entityState!.currentTemperature!)
    }

    func drawCurrentTemperture(_ rect: CGRect) {
        if (entityState!.currentTemperature == nil) {
            return
        }
        var p = CGPoint(x: rect.width , y:topY)
        let icon = UIImage.init(named: "thermometer.png")
        if (icon != nil) {
            p.x = p.x - icon!.size.width
            icon!.draw(at: p)
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs : [NSAttributedStringKey: Any] = [.paragraphStyle: paragraph, .font: tempertueFont!]
        let txt = NSString(format: "%.1f",entityState!.currentTemperature!)
        p.x = p.x - txt.size(withAttributes: attrs).width + 8
        p.y += 5
        txt.draw(at: p, withAttributes: attrs)
    }
    
    func drawSetTemperture(_ rect: CGRect) {
        
        if (entityState!.setTemperature == nil) {
//            let icon = UIImage.init(named: "nest-leaf-icon.png")
//            if (icon != nil) {
//                icon!.draw(at: CGPoint(x: paddingX + 8 , y: topY + 8))
//            }

            return
        }
        var textColor = UIColor.gray
        if (self.hvacStatus == "heating") {
            textColor = UIColor.red
        } else if (self.hvacStatus == "cooling") {
            textColor = UIColor.blue
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs : [NSAttributedStringKey: Any] = [.paragraphStyle: paragraph, .font: tempertueFont!,.foregroundColor: textColor]
//        let r = CGRect(x: paddingX + 6 , y: topY + 12, width: 20, height: 12)
        let r = CGRect(x: rect.width / 2 - 10 , y: topY + 12, width: 20, height: 12)
        let txt = NSString(format: "%.0f",entityState!.setTemperature!)
        txt.draw(in: r, withAttributes: attrs)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawSetTemperture(rect)
//        drawCurrentTemperture(rect)
    }

}
