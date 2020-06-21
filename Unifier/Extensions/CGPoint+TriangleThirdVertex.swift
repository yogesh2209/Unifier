//
//  CGPoint+TriangleThirdVertex.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/12/20.
//  Copyright © 2020. All rights reserved.
//

import UIKit

extension CGPoint {
    
    static func thirdVertexTriangle(leftPoint: CGPoint, rightPoint: CGPoint) -> CGPoint {
        let thirdX = 0.5 * (leftPoint.x + rightPoint.x  + (1.732 * leftPoint.y) - (1.732 * rightPoint.y))
        let thirdY = 0.5 * (leftPoint.y + rightPoint.y - (1.732 * leftPoint.x) + (1.732 * rightPoint.x))
        
        return CGPoint(x: thirdX, y: thirdY)
    }
    
}
