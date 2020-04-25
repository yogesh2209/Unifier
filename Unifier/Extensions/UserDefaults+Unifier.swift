//
//  UserDefaults+Unifier.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/25/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    private static let UserDefaultsDidPresentWalkThrough = "UserDefaultsDidPresentWalkThrough"
    
    var didPresentWalkThrouh: Bool {
        get {
            if let didComplete = self.value(forKey: UserDefaults.UserDefaultsDidPresentWalkThrough) as? Bool {
                return didComplete
            } else {
                self.setValue(false, forKey: UserDefaults.UserDefaultsDidPresentWalkThrough)
                return false
            }
        }
        
        set {
            self.setValue(newValue, forKey: UserDefaults.UserDefaultsDidPresentWalkThrough)
        }
    }
    
}
