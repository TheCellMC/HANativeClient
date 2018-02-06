//
//  StateButtonLock.swift
//  associate
//
//  Created by Roey Benamotz on 1/31/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class StateButtonLock : StateButtonBase {
    override func iconName() -> String? {
        return "lock-" + entityState!.state + ".png"
    }
    override func shouldDrawIconInMiddle() -> Bool {
        return true
    }

    
    override func additionalInfo() -> String? {
        if (entityState!.lockStatus == nil) {
            return nil
        }
        return self.entityState!.lockStatus
    }
    
    
    @objc override func buttonAction(sender: UIView) {
        let ha = HomeAssistantDao.shared
        var s = entityState!.state
        var service = "lock"
        if (s == "locked") {
            s = "unlocked"
            service = "unlock"
        }
        else if (s == "unlocked") {
            s = "locked"
            service = "lock"
        }
        entityState!.state = s
        ha.runService(domain: self.entityState!.platform, service: service, entityId: self.entityId)
    }

    
    
}
