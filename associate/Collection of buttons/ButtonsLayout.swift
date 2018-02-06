//
//  ButtonsLayout.swift
//  associate
//
//  Created by Roey Benamotz on 2/4/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit

class ButtonsLayout : UICollectionViewFlowLayout {
    override func awakeFromNib() {
        itemSize = CGSize(width: 90, height: 80)
        minimumLineSpacing = 0.0
        minimumInteritemSpacing = 10.0
        scrollDirection = .horizontal
    }
    
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        print ("kkk")
        return CGPoint(x:100, y:100)
    }
    
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        print (proposedContentOffset)
        return proposedContentOffset

    }
    
}
