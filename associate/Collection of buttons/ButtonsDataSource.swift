//
//  ButtonsDataSource.swift
//  associate
//
//  Created by Roey Benamotz on 2/4/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class ButtonsDataSource : NSObject, UICollectionViewDataSource {
    private var buttons = [StateButtonBase]()
    private var entityIds = [String: [StateButtonBase]]()
    
    private func addButton (state: HomeAssistantState) {
        let temp = StateButtonBase.Init(entityId: state.entityId)
        if (temp == nil) {
            return
        }
        let button = temp!
        button.entityState = state
        button.frame = CGRect(x:0, y:0, width: 90, height: 80)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        self.buttons.append(button)
        var gg = entityIds[state.entityId] ?? [StateButtonBase]()
        gg.append(button)
        entityIds[state.entityId] = gg
    }
    
    override init() {
        super.init()
        HomeAssistantDao.shared.events.listenTo(eventName: HomeAssistantDao.stateUpdatedEvent, action: self.statesUpdated)
    }
    
    func statesUpdated() {
        let ha = HomeAssistantDao.shared
        for s in ha.allStates.values {
            let buttons = entityIds[s.entityId]
            if (buttons != nil) {
                for b in buttons! {
                    b.entityState = s
                }
                continue
            }
            
            addButton(state: s)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let output = collectionView.dequeueReusableCell(withReuseIdentifier: "buttonCell", for: indexPath)
        output.backgroundColor = UIColor.blue
        output.addSubview(buttons[indexPath.item])
        return output
    }
    
}
