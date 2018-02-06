//
//  ButtonsList.swift
//  associate
//
//  Created by Roey Benamotz on 1/26/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit


struct UiElement {
    var entityId = ""
    var button : StateButtonBase
}
struct LayerProperties {
    var shadowOpacity : Float
    var shadowRadius: CGFloat
}


class ButtonsListController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate{
    
    var buttonCenter = CGPoint()
    var buttonHeight = 80
    var buttonWidth = 120
    let padding = 10
    let pageTitleHeight = 40
    var frameWidth = 0
    var buttonsPerRow = 1
    var leftMargin = 0
    var pageSize = 12
    var pageTitleLables = [Int: UITextField]()
    var positionIndicator = UIView()
    var scrollView : UIScrollView?
    var pageControl : UIPageControl?
    private var pagingTimer : Timer?
    //var pans =  [Int: UIPanGestureRecognizer]()
    var pans = [UIPanGestureRecognizer]()
    var userConfig : UserConfig?
    var allButtons = [String: StateButtonBase]()
    private var floatButtonOrigialLayerProperties: LayerProperties?

    override public func viewDidLoad() {
        super.viewDidLoad()
        frameWidth = Int(self.view.frame.width)
        let frameHeight = Int(self.view.frame.height) - pageTitleHeight - 10
        buttonWidth = frameWidth / 3 - padding  * 2
        buttonHeight = frameHeight / 6 - padding * 2
        buttonsPerRow = frameWidth / (buttonWidth + padding)
        pageSize = frameHeight  / (buttonHeight + padding * 2) * buttonsPerRow
        leftMargin = (frameWidth - buttonsPerRow * buttonWidth - (buttonsPerRow - 1) *  padding) / 2
        //Scroll view
        self.scrollView = UIScrollView(frame: self.view.frame)
        self.scrollView!.isPagingEnabled = true
        self.scrollView!.showsVerticalScrollIndicator = true
        self.scrollView!.isScrollEnabled = true
        self.scrollView!.delegate = self
        self.scrollView!.indicatorStyle = .white
        self.view.addSubview(self.scrollView!)
        //position indicator
        positionIndicator.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        positionIndicator.layer.cornerRadius = 5
        positionIndicator.clipsToBounds = true
        //Register to events
        self.userConfig = UserConfig.shared
        self.statesUpdated()
        HomeAssistantDao.shared.events.listenTo(eventName: HomeAssistantDao.stateUpdatedEvent, action: self.statesUpdated)
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.size.width);
        self.pageControl!.currentPage = page
    }
        private func statesUpdated() {
        for s in HomeAssistantDao.shared.allStates.values {
            let entityId = s.entityId
            let index = self.userConfig!.locationFor(entityId: entityId)
            let button = self.allButtons[s.entityId]
            if (button==nil) {
                self.addButton(entityId: entityId, atLocation: index)
                continue
            }
            button!.entityState = s
        }
    }
    
    
    private func setPageTitle (title: String, pageNumber: Int) {
        var label = pageTitleLables[pageNumber]
        if (label == nil) {
            let x = frameWidth * pageNumber
            label = UITextField(frame: CGRect(x: x, y: 0, width: frameWidth, height: pageTitleHeight))
            label!.layer.shadowColor = UIColor.black.cgColor
            label!.layer.shadowOpacity = 0.5
            label!.layer.shadowOffset = CGSize.zero
            label!.layer.shadowRadius = 1
            label!.font = UIFont.boldSystemFont(ofSize: CGFloat(Double(pageTitleHeight) * 0.65))
            label!.returnKeyType = .done
            label!.delegate = self
            label!.textAlignment = .center
            label!.textColor = UIColor.white
            label!.tag = pageNumber
            scrollView!.addSubview(label!)
            pageTitleLables[pageNumber] = label
        }
        var page = userConfig!.getOrCreatePage(pageNumber: pageNumber)
        page.title = title
        try! userConfig!.saveToDefaults()
        label!.text = title
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    private func createPage(pageNumber: Int) {
        if (pageTitleLables[pageNumber] != nil) {
            return
        }
        let p = userConfig!.getOrCreatePage(pageNumber: pageNumber)
        setPageTitle(title: p.title, pageNumber: pageNumber)
        self.scrollView!.contentSize = CGSize(width: frameWidth * (pageNumber + 1), height: Int(self.view.bounds.height))
        self.pageControl!.numberOfPages = pageTitleLables.count
    }
    
    private func viewForIndex(index: Int) -> UIView {
        let pageNumber = index / pageSize
        createPage(pageNumber: pageNumber)
        return self.scrollView!
    }
    
    private func buttonFrameByIndex (index: Int) -> CGRect {
        let pageNumber = index / pageSize
        let y = pageTitleHeight +  ((index % pageSize) / buttonsPerRow ) * (buttonHeight + padding)
        let x = (index % buttonsPerRow) * (buttonWidth + padding) + leftMargin + pageNumber * frameWidth
        
        return CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
    }
    
    private func findIndexByPoint (point: CGPoint) -> Int? {
        let x = Int(point.x) - leftMargin + padding / 2
        let y = Int(point.y) - pageTitleHeight
        let pageNumber = x / frameWidth
        var index = (x - pageNumber * frameWidth) / (buttonWidth + padding) + ((y / (buttonHeight + padding))) * buttonsPerRow
        if (index >= pageSize) {
            return nil
        }
        index = index + pageNumber * pageSize
        return index
    }
    
    private func addButton(entityId: String, atLocation: Int) {
        let temp = StateButtonBase.Init(entityId: entityId)
        if (temp == nil) {
            return
        }
//        print ("Adding \(entityId) at \(atLocation)")
        let button = temp!
        button.tag = atLocation
        button.frame = self.buttonFrameByIndex(index: atLocation)
        button.entityState = HomeAssistantDao.shared.allStates[entityId]
        //actions
        //button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        //add to view
        let v = viewForIndex(index: atLocation)
        v.addSubview(button)
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton))
        button.addGestureRecognizer(pan)
        pan.isEnabled = false
        pans.append(pan)
        //register
        self.allButtons[entityId] = button
        self.userConfig!.registerThingLocation(entityId: entityId, index: atLocation)
//        button.addGestureRecognizer(longPressRecognizer)
        
    }
    
    @objc private func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
    }
    
    func setButtonEditMode (editMode: Bool) {
        for pan in pans {
            pan.isEnabled = editMode
        }
    }

    func moveButtonToIndex (button: StateButtonBase , newIndex: Int) {
        let newFrame = self.buttonFrameByIndex(index: newIndex)
        button.tag = newIndex
        self.userConfig!.registerThingLocation(entityId: button.entityId, index: newIndex)
        let v = viewForIndex(index: newIndex)
        v.bringSubview(toFront: button)
        UIView.animate(withDuration: 0.2, animations: {
            button.frame = newFrame
        })
    }
    
    func scrollToPage(pageNumber: Int) {
        
        var frame = scrollView!.frame;
        frame.origin.x = frame.size.width * CGFloat(pageNumber);
        frame.origin.y = 0;
        pageControl?.currentPage = pageNumber
        scrollView?.scrollRectToVisible(frame, animated: true)
    }
    
    private func restoreButtonLayer(button: UIView) {
        if (floatButtonOrigialLayerProperties == nil) {
            return
        }
        let f = floatButtonOrigialLayerProperties!
        let layer = button.layer
        UIView.animate(withDuration: 0.2, animations: {
            layer.shadowOpacity = f.shadowOpacity
            layer.shadowRadius = f.shadowRadius
        })
        floatButtonOrigialLayerProperties = nil

    }

    @objc func panButton(pan: UIPanGestureRecognizer) {
        let location = pan.location(in: scrollView)
        let button = pan.view as! StateButtonBase
        if pan.state == .began {
            buttonCenter = button.center
            self.positionIndicator.frame = self.buttonFrameByIndex(index: button.tag)
            let v = viewForIndex(index: button.tag)
            v.addSubview(self.positionIndicator)
            v.bringSubview(toFront: button)
            let layer = button.layer
            floatButtonOrigialLayerProperties = LayerProperties(shadowOpacity: layer.shadowOpacity, shadowRadius: layer.shadowRadius)
            UIView.animate(withDuration: 0.2, animations: {
                button.layer.shadowOpacity = 1.0
                button.layer.shadowRadius = 30
            })

        } else if pan.state == .failed || pan.state == .cancelled {
            restoreButtonLayer(button: button)
            button.center = buttonCenter
            self.positionIndicator.removeFromSuperview()
        } else if pan.state == .ended {
            restoreButtonLayer(button: button)
            self.positionIndicator.removeFromSuperview()
            let originalIndex = button.tag
            let newIndex = findIndexByPoint(point: pan.location(in: self.scrollView))
            if (newIndex==nil) {
                self.moveButtonToIndex(button: button, newIndex: originalIndex)
                return
            }
            HomeAssistantDao.shared.isPaused = true
            let otherButton = self.scrollView!.viewWithTag(newIndex!) as? StateButtonBase
            if (otherButton != nil) {
                self.moveButtonToIndex(button: otherButton!, newIndex: originalIndex)
            }
            self.moveButtonToIndex(button: button, newIndex: newIndex!)
            
            HomeAssistantDao.shared.isPaused = false
        } else {
            button.center = location
            let physicalX = pan.location(in: self.view).x
            if (physicalX > self.view.frame.width - CGFloat(40.0)) {
                if (pagingTimer == nil) {
                    pagingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.scrollRight), userInfo: nil, repeats: false)
                }
                return
            }
            if (physicalX < CGFloat(40.0)) {
                if (pagingTimer == nil) {
                    pagingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.scrollLeft), userInfo: nil, repeats: false)
                }
                return
            }
            if (pagingTimer != nil) {
                pagingTimer!.invalidate()
                pagingTimer = nil
            }
            let temp = findIndexByPoint(point: pan.location(in: self.scrollView))
            if (temp == nil) {
                self.positionIndicator.isHidden = true
            } else {
                self.positionIndicator.isHidden = false
                let r = self.buttonFrameByIndex(index: temp!)
                UIView.animate(withDuration: 0.1, animations: {
                    self.positionIndicator.frame = r
                })
            }
        }
    }
    
    @objc private func scrollLeft() {
        self.pagingTimer!.invalidate()
        self.pagingTimer = nil
        let newPageNumber = self.pageControl!.currentPage - 1
        self.scrollToPage(pageNumber: newPageNumber)
    }
    @objc private func scrollRight() {
        self.pagingTimer!.invalidate()
        self.pagingTimer = nil
        let newPageNumber = self.pageControl!.currentPage + 1
        createPage(pageNumber: newPageNumber)
        self.scrollToPage(pageNumber: newPageNumber)
    }
    //UITextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pageNumber = textField.tag
        var page = userConfig!.getOrCreatePage(pageNumber: pageNumber)
        page.title = textField.text!
        userConfig!.setPage(page: page)
    }
}
