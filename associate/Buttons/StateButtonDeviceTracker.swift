//
//  StateButtonDeviceTracker.swift
//  associate
//
//  Created by Roey Benamotz on 2/4/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//
import UIKit

class StateButtonDeviceTracker : StateButtonBase {
    
    override func additionalInfo() -> String? {
        return self.entityState!.state
    }
    override func isActionble() -> Bool {
        return false
    }
    
    
    override func iconName() -> String? {
        return "map-location.png"
    }
    
}


