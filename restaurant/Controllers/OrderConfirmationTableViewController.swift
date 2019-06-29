//
//  OrderConfirmationTableViewController.swift
//  restaurant
//
//  Created by love on 6/25/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

class OrderConfirmationTableViewController: UITableViewController {

    var seconds: Int!
    var order: Order!
    var preparationTime: Int! {
        didSet {
            self.seconds = self.preparationTime * 60
            self.runTimer()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var preparationTimeLabel: UILabel!
    var formattedPreparationTime: String {
        get {
            let hour = Int(self.seconds) / 3600
            let min = Int(self.seconds) / 60 % 60
            let sec = Int(self.seconds) % 60
            return String(format: "%02i:%02i:%02i", hour, min, sec)
        }
    }
    
    var timer: Timer?
    var isTimerRunning = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.cornerRadius = 50
        self.imageView.clipsToBounds = true

        
        self.tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: "MenuItemTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuItemTableViewCell")
        
        tableView.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressTableViewCell")
        
        tableView.register(UINib(nibName: "PriceTableViewCell", bundle: nil), forCellReuseIdentifier: "PriceTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return self.order.items.count
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for:
            indexPath) as! MenuItemTableViewCell

            let index = indexPath.row
            
            let orderItem = self.order.items[index]
            
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
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for:
                indexPath) as! AddressTableViewCell
            
            cell.titleLabel?.text = self.order.address?.title
            cell.subtitleLabel?.text = self.order.address?.address
            
            return cell
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PriceTableViewCell", for:
                indexPath) as! PriceTableViewCell
            
            let orderTotalPrice = order.items.reduce(0.0) {
                (result, item) -> Double in
                return result + (item.menuItem?.price)!
            }
            
            let formattedOrderPrice = String(format: "$%.2f", orderTotalPrice)
            cell.titleLabel?.text = formattedOrderPrice
            
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateOrderTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateOrderTime() {
        self.seconds -= 1
        
        preparationTimeLabel.text = self.formattedPreparationTime
        
        if self.seconds == 0 {
            self.timer?.invalidate()
            
            let title = "Your Order Is Ready"
            let message = "your order is ready to ship"
            let alert = AlertService.getInfoAlertController(title: title, message: message)

            present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 2 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 60
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
