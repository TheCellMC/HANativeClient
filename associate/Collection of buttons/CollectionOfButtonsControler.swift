//
//  CollectionOfButtonsControler.swift
//  associate
//
//  Created by Roey Benamotz on 2/3/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit



class CollectionOfButtonsControler : UIViewController {
    @IBOutlet weak var buttonsCollection: UICollectionView!
    let buttonsDataSource = ButtonsDataSource()
    
    
    override public func viewDidLoad() {
        self.buttonsCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.buttonsCollection.dataSource = buttonsDataSource
        HomeAssistantDao.shared.events.listenTo(eventName: HomeAssistantDao.stateUpdatedEvent, action: self.statesUpdated)
    }
    
    func statesUpdated() {
        self.buttonsCollection.reloadData()
    }
    
//    private func addButton (state: HomeAssistantState) {
//        let temp = StateButtonBase.Init(entityId: state.entityId)
//        if (temp == nil) {
//            return
//        }
//        let button = temp!
//        self.buttonsCollection.apped
//        button.frame = self.buttonFrameByIndex(index: index)
//        button.layer.masksToBounds = true
//        button.layer.cornerRadius = 5
//        //sync button
//        let element = UiElement(entityId: entityId, button: button)
//        syncButtonToState(element: element)
//        //actions
//        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        //register
//        self.buttons[index] = element
//        button.tag = index
//        //add to view
//        let v = viewForIndex(index: index)
//        v.addSubview(button)
//        //        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton))
//        button.addGestureRecognizer(pan)
//        pan.isEnabled = false
//        pans.append(pan)
//        //        button.addGestureRecognizer(longPressRecognizer)
//
//    }

    
}
