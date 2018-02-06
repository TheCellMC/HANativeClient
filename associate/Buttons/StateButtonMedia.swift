//
//  StateButtonLock.swift
//  associate
//
//  Created by Roey Benamotz on 1/31/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class StateButtonMedia : StateButtonBase {
    override func iconName() -> String? {
        if (entityState!.state == "off") {
            return "media-off.png"
        }
        if (entityState!.state == "playing") {
            return "media-paused.png"
        }
        if (entityState!.state == "paused") {
            return "media-playing.png"
        }
        return "media.png"
    }
    
    
    override func buttonAction(sender: UIView) {
        let ha = HomeAssistantDao.shared
        ha.runService(domain: self.entityState!.platform, service: "media_play_pause", entityId: self.entityId)
    }

    override func additionalInfo() -> String? {
        return self.entityState!.mediaTitle
    }

}

