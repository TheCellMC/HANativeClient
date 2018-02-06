//
//  StateButtonLight.swift
//  associate
//
//  Created by Roey Benamotz on 1/28/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class GenericSensor : StateButtonBase {
    
    override func isActionble() -> Bool {
        return false
    }
    
    override func iconName() -> String? {
        return "switch-" + entityState!.state + ".png"
    }
    
    
    func drawState(_ rect: CGRect) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs : [NSAttributedStringKey: Any] = [.paragraphStyle: paragraph, .font: titleFont!, .foregroundColor: UIColor.black]
        let a = NSAttributedString(string: self.entityState!.state, attributes: attrs)
        let r = CGRect(x: 0, y: Int(topY), width: Int(rect.width), height: Int(titleFont!.lineHeight) * 2)
        a.draw(in: r)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawState (rect)
        
    }
    
}


