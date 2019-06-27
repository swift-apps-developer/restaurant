//
//  OrderTableViewController.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

class OrderTableViewController: UITableViewController {
    var orderItems = [OrderItem]()
    var editButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarStyle()
        tableView.register(UINib(nibName: "MenuItemTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuItemTableViewCell")
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: 15)!], for: UIControl.State.normal)

        self.setBarButtons()

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: MenuService.orderUpdatedNotification, object: nil)
        
        updateUI()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    @objc func updateUI() {
        let order = MenuService.shared.getLatestOrder()
        if let order = order, order.items.count > 0 {
            self.orderItems = Array(order.items)
            navigationItem.rightBarButtonItem!.isEnabled = true
        } else {
            self.orderItems = []
            navigationItem.rightBarButtonItem!.isEnabled = false
        }
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for:
            indexPath) as! MenuItemTableViewCell

        let index = indexPath.row
        
        let orderItem = self.orderItems[index]
            
        cell.itemTitleLabel?.text = orderItem.menuItem?.name
        cell.itemPriceLabel?.text = String(format: "$%.2f", (orderItem.menuItem?.price)!)
        cell.itemImageView.layer.cornerRadius = 7
        
        let imageURL = URL(string: (orderItem.menuItem?.imageURL)!)!
        MenuService.shared.fetchImage(for: imageURL, completionHandler: { (image) in
            guard let image = image else {return}
            DispatchQueue.main.async {
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath != indexPath {
                    return
                }
                cell.itemImageView?.image = image
                cell.setNeedsLayout()
            }
        })
        

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            let orderItem = self.orderItems[index]
            MenuService.shared.removeOrderItem(orderItemId: orderItem.id)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MenuSegueFromOrderIdentifier" {
            let index = self.tableView.indexPathForSelectedRow?.row
            let menuDetailViewController = segue.destination as! MenuDetailViewController
            menuDetailViewController.item = self.orderItems[index!].menuItem
        }
    }
    
    
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBAction func forwardButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SelectAddressIdentifier", sender: nil)
    }

    func setBarButtons() {
        self.setRightBarButton()
        self.setLeftBarButton()
    }
    
    func setRightBarButton() {
        let forwardButton = UIButton(type: .system)
        forwardButton.titleLabel?.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        forwardButton.setTitle("\u{f30b}", for: .normal)
        forwardButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        forwardButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20.0)
        forwardButton.addTarget(self, action: #selector(self.forwardButtonTapped(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: forwardButton)
    }
    
    func setLeftBarButton() {
        self.editButton = UIButton(type: .system)
        self.editButton.titleLabel?.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        self.editButton.setTitle("\u{f044}", for: .normal)
        self.editButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.editButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20.0, bottom: 0, right: 0)
        self.editButton.addTarget(self, action: #selector(self.editButtonTapped(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.editButton)
    }
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        if self.tableView.isEditing {
            self.editButton.setTitle("\u{f058}", for: .normal)
        } else {
            self.editButton.setTitle("\u{f044}", for: .normal)
        }
    }
    
}
