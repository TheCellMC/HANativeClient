//
//  StateButtonLock.swift
//  associate
//
//  Created by Roey Benamotz on 1/31/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class StateButtonCover : StateButtonBase {
    override func iconName() -> String? {
        return "cover-" + entityState!.state + ".png"
    }
    override func shouldDrawIconInMiddle() -> Bool {
        return true
    }

        
}


