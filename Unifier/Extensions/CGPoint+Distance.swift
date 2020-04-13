//
//  CGPoint+Distance.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/12/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit

extension CGPoint {
    
    static func distanceBetweenPoints(leftPoint: CGPoint, rightPoint: CGPoint) -> CGFloat {
        let xDistance = leftPoint.x - rightPoint.x
        let yDistance = leftPoint.y - rightPoint.y
        
        return CGFloat(sqrt(xDistance * xDistance + yDistance * yDistance))
    }
    
}
