//
//  Article.swift
//  associate
//
//  Created by Roey Benamotz on 1/18/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

struct HomeAssistantState  {
    
    var entityId: String
    var platform : String
    var state: String
    var friendlyName: String
    var brightness : Float?
    var currentTemperature : Float?
    var setTemperature : Float?
    var operationMode : String?
    var lockStatus: String?
    var mediaTitle: String?
    var isHiddens = false
    
    
    
    enum CodingKeys: String, CodingKey {
        case entity_id
        case state
        case attributes
    }
    
    enum AdditionalInfoKeys: String, CodingKey {
        case friendly_name
        case brightness
        case current_temperature
        case temperature
        case operation_mode
        case lock_status
        case media_title
        case hidden
    }
    
    
}

extension HomeAssistantState : Decodable {
    init (from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entityId = try values.decode(String.self, forKey: .entity_id)
        state = try values.decode(String.self, forKey: .state)
        
        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .attributes)
        if (additionalInfo.contains(.friendly_name)) {
            friendlyName = try additionalInfo.decode(String.self , forKey: .friendly_name)
        } else {
            friendlyName = entityId
        }
        let p = entityId.index(of: ".")
        platform = String(entityId[..<p!])


        if (additionalInfo.contains(.brightness)) {
            brightness = try additionalInfo.decode(Float.self , forKey: .brightness)
        }
        if (additionalInfo.contains(.current_temperature)) {
            currentTemperature = try? additionalInfo.decode(Float.self , forKey: .current_temperature)
        }
        if (additionalInfo.contains(.temperature)) {
            setTemperature = try? additionalInfo.decode(Float.self , forKey: .temperature)
        }
        if (additionalInfo.contains(.operation_mode)) {
            operationMode = try? additionalInfo.decode(String.self, forKey: .operation_mode)
        }
        if (additionalInfo.contains(.lock_status)) {
            lockStatus = try? additionalInfo.decode(String.self, forKey: .lock_status)
        }
        if (additionalInfo.contains(.media_title)) {
            mediaTitle = try? additionalInfo.decode(String.self, forKey: .media_title)
        }
        if (additionalInfo.contains(.hidden)) {
            let temp  = try? additionalInfo.decode(Bool.self, forKey: .hidden)
            isHiddens = temp ?? false
        }

    }
}
