//
//  UIDevice+iPad.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/12/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit

extension UIDevice {
    public static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

