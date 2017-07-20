//
//  UIAlertController+Extensions.swift
//  iCrac
//
//  Created by Rémi Caroff on 20/07/2017.
//  Copyright © 2017 Crac. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    func show() {
        
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(self, animated: true, completion: nil)
        
    }
    
}
