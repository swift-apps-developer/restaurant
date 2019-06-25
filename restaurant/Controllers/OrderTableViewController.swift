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
    @IBOutlet weak var proceedBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.register(UINib(nibName: "MenuItemTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuItemTableViewCell")

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
            self.proceedBarButton.isEnabled = true
        } else {
            self.orderItems = []
            self.proceedBarButton.isEnabled = false
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
}
