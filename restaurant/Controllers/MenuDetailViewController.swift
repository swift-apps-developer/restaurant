//
//  MenuDetailViewController.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

class MenuDetailViewController: UIViewController {
    var item: MenuItem?

    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var menuPriceLabel: UILabel!
    @IBOutlet weak var menuDescriptionLabel: UILabel!
    @IBOutlet weak var addOrderButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.menuImageView.layer.cornerRadius = 7
        self.menuImageView.clipsToBounds = true
        
        self.addOrderButton.layer.cornerRadius = 7
        self.addOrderButton.clipsToBounds = true
        
        self.setBarButtons()
        
        self.title = item?.name
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        guard let item = self.item else {
            return
        }
        coder.encode(item.id, forKey: "menuItemId")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        let itemId = coder.decodeInteger(forKey: "menuItemId")
        
        self.item = MenuService.shared.getMenuItemById(id: itemId)
        self.updateUI()
    }
    
    func updateUI() {
        guard let item = self.item else {
            NotificationCenter.default.post(name: AlertService.infoAlertNotification, object: nil, userInfo: ["title": Messages.menuItemNotFoundErrorTitle, "message": Messages.menuItemNotFoundErrorMessage])
            return
        }
        self.menuNameLabel.text = item.name
        self.menuPriceLabel.text = "$ \(item.price)"
        self.menuDescriptionLabel.text = item.detailText
        
        let imageURL = URL(string: item.imageURL)!
        MenuService.shared.fetchImage(for: imageURL) {
            (image) in
            guard let image = image else {return}
            DispatchQueue.main.async {
                self.menuImageView.image = image
            }
        }
    }
    
    @IBAction func addOrderButtonTapped(_ sender: UIButton) {
        guard let item = self.item else {
            NotificationCenter.default.post(name: AlertService.infoAlertNotification, object: nil, userInfo: ["title": Messages.menuItemNotFoundErrorTitle, "message": Messages.menuItemNotFoundErrorMessage])
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.addOrderButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.addOrderButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        MenuService.shared.addToOrder(menuItem: item)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setBarButtons() {
        self.setLeftBarButton()
    }
    
    func setLeftBarButton() {
        let backButton = UIButton(type: .system)
        backButton.titleLabel?.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        backButton.setTitle("\u{f30a}", for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10.0, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}
