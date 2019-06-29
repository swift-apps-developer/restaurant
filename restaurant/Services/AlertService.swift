//
//  AlertService.swift
//  restaurant
//
//  Created by love on 6/28/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import UIKit


class AlertService {
    static func getAlertControllerWithAction(title: String, message: String, actionTitle: String, actionCompletion: @escaping () -> Void) -> AlertViewController {
        
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        
        let alertViewContoller = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        
        alertViewContoller.alertTitle = title
        alertViewContoller.alertMessage = message
        alertViewContoller.actionTitle = actionTitle
        alertViewContoller.actionHandler = actionCompletion
        
        return alertViewContoller
    }
    
    static func getInfoAlertController(title: String, message: String) -> AlertViewController {
        
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        
        let alertViewContoller = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        
        alertViewContoller.alertTitle = title
        alertViewContoller.alertMessage = message
        alertViewContoller.isInfoAlert = true
        
        return alertViewContoller
    }
}
