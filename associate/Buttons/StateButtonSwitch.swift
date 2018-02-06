//
//  StateButtonLight.swift
//  associate
//
//  Created by Roey Benamotz on 1/28/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class StateButtonSwitch : StateButtonBase {

    override func shouldDrawIconInMiddle() -> Bool {
        return true
    }

    
    override func iconName() -> String? {
        return "switch-" + entityState!.state + ".png"
    }
    
}

