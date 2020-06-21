//
//  UIView+Blur.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/13/20.
//  Copyright © 2020. All rights reserved.
//

import UIKit

extension UIView {
    
    func addBlur(style: UIBlurEffect.Style = .dark) {
        let blurView = UIVisualEffectView(frame: self.bounds)
        let blurEffect = UIBlurEffect(style: style)
        blurView.effect = blurEffect
        self.insertSubview(blurView, at: 0)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    }
    
}

