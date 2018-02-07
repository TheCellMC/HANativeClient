//
//  ButtonMatrix.swift
//  associate
//
//  Created by Roey Benamotz on 2/6/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class ButtonListDataSource {
    var buttonsByLocation = [Int: StateButtonBase]()
    var buttonsByEntityId = [String: StateButtonBase]()
    var pageTitleLables = [Int: UITextField]()
    
    //Buttons
    func registerButton (index: Int, button: StateButtonBase) {
        buttonsByLocation[index] = button
        buttonsByEntityId[button.entityId] = button
        let u = UserConfig.shared
        u.register(entityId: button.entityId, atIndex: index)
    }
    
    func buttonBy (location: Int) -> StateButtonBase? {
        return buttonsByLocation[location]
    }

    func buttonBy (entityId: String) -> StateButtonBase? {
        return buttonsByEntityId[entityId]
    }
    
    //Pages
    func register (textField: UITextField, forPage: Int){
        pageTitleLables[forPage] = textField
    }
    
    
    func pageTextFieldBy (pageNumber: Int) -> UITextField? {
        return pageTitleLables[pageNumber]
    }
    func countPages() -> Int {
        return pageTitleLables.count
    }
}
