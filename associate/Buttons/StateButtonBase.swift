//
//  StateButtonBase.swift
//  associate
//
//  Created by Roey Benamotz on 1/28/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class StateButtonBase : UIButton {
    let topY = CGFloat(5)
    var paddingX = CGFloat(5)
    let moreInfoX = CGFloat(32)
    let moreInfoY = CGFloat(15)
    private var _state : HomeAssistantState?
    private var _entityId  = ""
    private var isInSliderMode = false
    private var originalFramne : CGRect?
    private var blurredView : UIView?
    
    var entityState: HomeAssistantState? {
        get {return _state}
        set {
            _state = newValue
            self.setNeedsDisplay()
        }
    }
    var entityId : String {
        get {return _entityId}
    }
    let titleFont = UIFont(name: "GeezaPro-Bold", size: 11)
    var moreInfoFont = UIFont(name: "GeezaPro", size: 9)
    
    static let supportedPlatforms = ["switch","light","climate","sensor","lock","media_player","cover","scene"]

    func isActionble() -> Bool {
        return true
    }


    
    static func Init(entityId: String) -> StateButtonBase? {
        var output : StateButtonBase? = nil
        if (entityId.hasPrefix("switch")) {
            output = StateButtonSwitch()
        } else if (entityId.hasPrefix("light")) {
            output = StateButtonLight()
        } else if (entityId.hasPrefix("climate")) {
            output = StateButtonClimate()
        } else if (entityId.hasPrefix("sensor")) {
            output = GenericSensor()
        } else if (entityId.hasPrefix("device_tracker")) {
            output = StateButtonDeviceTracker()
        } else if (entityId.hasPrefix("lock")) {
            output = StateButtonLock()
        } else if (entityId.hasPrefix("media_player")) {
            output = StateButtonMedia()
        } else if (entityId.hasPrefix("scene")) {
            output = StateButtonScene()
        } else if (entityId.hasPrefix("cover")) {
            output = StateButtonCover()
        }

        if (output == nil) {
            return nil
        }
        let btn = output!
        btn._entityId = entityId
        btn.backgroundColor = UIColor.white
        if btn.isActionble() {
            btn.addTarget(output!, action: #selector(touchDown), for: .touchDown)
            btn.addTarget(output!, action: #selector(touchUpOfAnyKind), for: .touchCancel)
            btn.addTarget(output!, action: #selector(touchUpOfAnyKind), for: .touchUpInside)
            btn.addTarget(output!, action: #selector(touchUpOfAnyKind), for: .touchUpOutside)
            btn.addTarget(output!, action: #selector(buttonAction), for: .touchUpInside)
        }
//        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize.zero
        btn.layer.shadowRadius = 5
        return output
    }
    
    internal func iconName() -> String? {
        return nil
    }
    internal func additionalInfo() -> String? {
        return nil
    }
    
    internal func shouldDrawIconInMiddle() -> Bool{
        return true
    }

    @objc private func touchDown(sender: UIView) {
        sender.backgroundColor = UIColor.gray
    }
    
    @objc private func touchUpOfAnyKind(sender: UIView) {
//        return;
        sender.backgroundColor = UIColor.white
        if (!isInSliderMode) {
            return;
        }
        UIView.animate(withDuration: 0.2, animations: {
            sender.frame = self.originalFramne!
        })
        isInSliderMode = false
        if (blurredView != nil) {
            blurredView!.removeFromSuperview()
            blurredView = nil
        }
    }
    
    @objc internal func buttonAction(sender: UIView) {
//        print ("slider mode: \(isInSliderMode)")
        if (isInSliderMode) {
            return
        }
        let ha = HomeAssistantDao.shared
        var s = entityState!.state
        var service = "toggle"
        if (s == "off") {
            s = "on"
            service = "turn_on"
        }
        else if (s == "on") {
            s = "off"
            service = "turn_off"
        }
        entityState!.state = s
        ha.runService(domain: self.entityState!.platform, service: service, entityId: self.entityId)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch == nil) {
            return
        }
//        print (touch!.location(in: self))
        let force = touch!.force / touch!.maximumPossibleForce
        if (force >= 0.5 && !isInSliderMode) {
            self.originalFramne = self.frame
            let viewFrame = self.superview!.frame
            blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blurredView!.frame = self.superview!.bounds
            self.superview!.addSubview(blurredView!)
            self.superview!.bringSubview(toFront: self)
            self.backgroundColor = UIColor.white
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.masksToBounds = true
                self.layer.cornerRadius = 10
                self.frame = viewFrame.insetBy(dx: 120, dy: 120)
            })

            isInSliderMode = true
        }
    }
    
    

    func drawAdditionalInfo(_ rect: CGRect) {
        let text = additionalInfo()
        if (text == nil) {
            return
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping
        let attrs : [NSAttributedStringKey: Any] = [.paragraphStyle: paragraph, .font: moreInfoFont!, .foregroundColor: UIColor.black]
        let a = NSAttributedString(string: text!, attributes: attrs)
        a.draw(in: rect)
    }


    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if (_state == nil) {
            return;
        }
        //Icon
        if (iconName() != nil) {
            let icon = UIImage.init(named: iconName()!)
            if (icon != nil) {
                var p = CGPoint(x: paddingX, y:topY)
                if (shouldDrawIconInMiddle()) {
                   p.x = (rect.width - icon!.size.width) / 2
                }
                icon!.draw(at: p)
            }
        }

        //Title
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs : [NSAttributedStringKey: Any] = [.paragraphStyle: paragraph, .font: titleFont!, .foregroundColor: UIColor.black]
        let a = NSAttributedString(string: _state!.friendlyName, attributes: attrs)
        let h = titleFont!.lineHeight * 2 + 2
        let w = rect.width - paddingX * 2
        let actualR = a.boundingRect(with: CGSize(width:w, height: h ), options: .usesLineFragmentOrigin, context: nil)
        let y = rect.height - 10 - titleFont!.lineHeight * 2 - 4 + (h - actualR.height) / 2
        let r = CGRect(x: paddingX, y: y, width: w, height: h)
        a.draw(in: r)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x:paddingX, y:rect.height - 13))
        path.addLine(to: CGPoint(x:rect.width - paddingX, y: path.currentPoint.y))
        path.close()
        UIColor.gray.set()
        path.stroke()
        
        let additionalInfoRect = CGRect(x: paddingX, y: rect.height - 12, width: w, height: 11)
        drawAdditionalInfo(additionalInfoRect)
    }
    
}
