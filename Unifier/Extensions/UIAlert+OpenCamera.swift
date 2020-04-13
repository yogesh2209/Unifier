//
//  UIAlert+OpenCamera.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/12/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func openCameraPrompt(openCameraAction: @escaping (() -> Void), openGalleryAction: @escaping (() -> Void), cancelAction: @escaping (() -> Void)) -> UIAlertController {
        
        
        let alertController = UIAlertController(title: "Select Image",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let openCamera = UIAlertAction(title: "Camera", style: .default) { action in
            openCameraAction()
        }
        
        let openGallery = UIAlertAction(title: "Photo Library", style: .default) { action in
            openGalleryAction()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            cancelAction()
        }
        
        alertController.addAction(openCamera)
        alertController.addAction(openGallery)
        alertController.addAction(cancel)
        
        return alertController
    }
    
    static func noActionPrompt(title: String? = nil, message: String? = nil, cancelAction: @escaping (() -> Void)) -> UIAlertController {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
       
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { action in
            cancelAction()
        }
     
        alertController.addAction(cancel)
        
        return alertController
    }
    
    /// Configure PopoverView presentation for iPad
    func configurePopOver(for view: UIView) {
        if let popover = self.popoverPresentationController, UIDevice.isIPad {
            self.modalPresentationStyle = .popover
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
    }
}


