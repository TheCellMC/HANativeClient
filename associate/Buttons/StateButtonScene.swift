//
//  StateButtonScene.swift
//  associate
//
//  Created by Roey Benamotz on 2/4/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class StateButtonScene : StateButtonBase {
    
    override func shouldDrawIconInMiddle() -> Bool {
        return true
    }
    
    
    override func iconName() -> String? {
        return "scene.png"
    }
    
}

