//
//  AlertViewController.swift
//  restaurant
//
//  Created by love on 6/28/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    var actionTitle: String?
    var alertMessage: String!
    var alertTitle: String!
    
    var isInfoAlert: Bool = false
    
    var actionHandler: (() -> Void)?
    var infoHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    func setupUI() {
        self.titleLabel.text = self.alertTitle
        self.messageLabel.text = self.alertMessage
        if let actionTitle = self.actionTitle {
            self.actionButton.setTitle(actionTitle, for: .normal)
        }
        
        if isInfoAlert {
            self.actionButton.isHidden = true
            self.cancelButton.isHidden = true
            self.okButton.isHidden = false
        } else {
            self.actionButton.isHidden = false
            self.cancelButton.isHidden = false
            self.okButton.isHidden = true
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if let actionHandler = self.actionHandler {
            actionHandler()
        }
    }
    @IBAction func okButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        if let infoHandler = self.infoHandler {
            infoHandler()
        }
    }
}
