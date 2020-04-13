//
//  UIImagePickerController+PopOver.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/12/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit

extension UIImagePickerController {
    
    /// Configure PopoverView presentation for iPad
    func configurePopOver(for view: UIView) {
        if let popover = self.popoverPresentationController, UIDevice.isIPad {
            self.modalPresentationStyle = .popover
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
    }
    
}
