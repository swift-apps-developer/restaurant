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

        self.addOrderButton.layer.cornerRadius = 7
        self.addOrderButton.clipsToBounds = true
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
        guard let item = self.item else {return}
        self.menuNameLabel.text = item.name
        self.menuPriceLabel.text = "$ \(item.price)"
        self.menuDescriptionLabel.text = item.detailText
        
        MenuService.shared.fetchImage(for: item.imageURL) {
            (image) in
            guard let image = image else {return}
            DispatchQueue.main.async {
                self.menuImageView.image = image
            }
        }
    }
    
    @IBAction func addOrderButtonTapped(_ sender: UIButton) {
        guard let item = self.item else {return}
        
        UIView.animate(withDuration: 0.3) {
            self.addOrderButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.addOrderButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        MenuService.shared.order.items.append(item)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
