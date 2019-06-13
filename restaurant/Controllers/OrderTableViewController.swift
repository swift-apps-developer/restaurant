//
//  OrderTableViewController.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

class OrderTableViewController: UITableViewController {
    var preparationTime: Int?
    @IBOutlet weak var submitOrderButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: MenuService.orderUpdatedNotification, object: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    @objc func updateUI() {
        self.tableView.reloadData()
        if MenuService.shared.order.items.count > 0 {
            self.submitOrderButton.isEnabled = true
        } else {
            self.submitOrderButton.isEnabled = false
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MenuService.shared.order.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemIdentifier", for: indexPath) as! MenuItemTableViewCell

        let index = indexPath.row
        let menuItem = MenuService.shared.order.items[index]
        
        cell.itemTitleLabel?.text = menuItem.name
        cell.itemPriceLabel?.text = String(format: "$%.2f", menuItem.price)
        cell.itemImageView.layer.cornerRadius = 7
        
        MenuService.shared.fetchImage(for: menuItem.imageURL, completionHandler: { (image) in
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
            MenuService.shared.order.items.remove(at: indexPath.row)
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
        if segue.identifier == "OrderConfirmationSegue" {
            let orderConfirmationViewController = segue.destination as! OrderConfirmationViewController
            orderConfirmationViewController.preparationTime = self.preparationTime!
        } else if segue.identifier == "MenuSegueFromOrderIdentifier" {
            let menuDetailViewController = segue.destination as! MenuDetailViewController
            let index = tableView.indexPathForSelectedRow!.row
            menuDetailViewController.item = MenuService.shared.order.items[index]
        }
    }
    
    
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        if segue.identifier == "BackToOrderListSegue" {
            MenuService.shared.order.items.removeAll()
        }
    }

    @IBAction func submitOrderButtonTapped(_ sender: Any) {
        let orderTotalPrice = MenuService.shared.order.items.reduce(0.0) {
            (result, item) -> Double in
            return result + item.price
        }
        
        let formattedOrderPrice = String(format: "$%.2f", orderTotalPrice)
        let alert = UIAlertController(title: "Confirm Order", message: "You are about to submit your order with a total of \(formattedOrderPrice)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default){
            action in
            self.submitOrder()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func submitOrder() {
        let menuIDs = MenuService.shared.order.items.map {$0.id}
        
        MenuService.shared.sumitOrderWith(menuIDs: menuIDs) {
            (min: Int?) in
            if let preparationTime = min {
                DispatchQueue.main.async {
                    self.preparationTime = preparationTime
                    self.performSegue(withIdentifier: "OrderConfirmationSegue", sender: self.tableView)
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
