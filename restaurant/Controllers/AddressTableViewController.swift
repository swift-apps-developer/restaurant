//
//  AddressTableViewController.swift
//  restaurant
//
//  Created by love on 6/23/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

class AddressTableViewController: UITableViewController {
    var preparationTime: Int?
    var addresses: [Address] = []
    var editButton: UIButton!
    var proceedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarStyle()
        
        self.tableView.allowsSelectionDuringEditing = true;
        self.setBarButtons()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: MenuService.addressesUpdatedNotification, object: nil)
        
        self.updateUI()
    }
    
    @objc func updateUI() {
        self.addresses = MenuService.shared.getAddresses() ?? []
        let hasDefaultAddress = self.addresses.filter{
            (address) -> Bool in
            return address.isDefault
        }
        
        if self.addresses.count > 0 && hasDefaultAddress.count > 0 {
            self.proceedButton.isEnabled = true
        } else {
            self.proceedButton.isEnabled = false
        }

        self.tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.addresses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressIdentifier", for: indexPath)

        let index = indexPath.row
        
        let address = self.addresses[index]
        
        cell.textLabel?.text = address.title
        cell.detailTextLabel?.text = address.address
        
        if address.isDefault {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

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
            let address = self.addresses[indexPath.row]
            MenuService.shared.removeAddress(address)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let address = self.addresses[indexPath.row]
        MenuService.shared.setDefaultAddress(for: address)
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
        if segue.identifier == "OrderConfirmationSegue" {
            let orderConfirmationViewController = segue.destination as! OrderConfirmationTableViewController
            let order = MenuService.shared.getLatestOrder()!
            let defaultAddress = self.addresses.filter{
                (address) -> Bool in
                return address.isDefault
                }.first
            MenuService.shared.setAddressForOrder(defaultAddress!)
            
            orderConfirmationViewController.order = order
            orderConfirmationViewController.preparationTime = self.preparationTime!
        }
        else if segue.identifier == "EditAddressSegue" {
            let addressViewController = segue.destination as! ShipmentTableViewController
            let index = self.tableView.indexPathForSelectedRow?.row
            let address = self.addresses[index!]
            addressViewController.address = address
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "EditAddressSegue" && !tableView.isEditing {
            return false
        }
        
        return true
    }
 
    
    @IBAction func submitOrderButtonTapped(_ sender: Any) {
        guard let order = MenuService.shared.getLatestOrder() else {return}
        let orderTotalPrice = order.items.reduce(0.0) {
            (result, item) -> Double in
            return result + (item.menuItem?.price)!
        }
        
        let formattedOrderPrice = String(format: "$%.2f", orderTotalPrice)
        
        let title = "Confirm Order"
        let message = "You are about to submit your order with a total of \(formattedOrderPrice)"
        
        let alert = AlertService.getAlertControllerWithAction(title: title, message: message, actionTitle: "Submit") { [weak self] in
            self?.submitOrder()
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func submitOrder() {
        guard let order = MenuService.shared.getLatestOrder() else {return}
        let menuIDs = Array(order.items.map {($0.menuItem?.id)!})
        
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
    
    func setBarButtons() {
        self.setRightBarButton()
        self.setLeftBarButton()
    }
    
    func setRightBarButton() {
        self.proceedButton = UIButton(type: .system)
        self.proceedButton.titleLabel?.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        self.proceedButton.setTitle("\u{f30b}", for: .normal)
        self.proceedButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.proceedButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20.0)
        self.proceedButton.addTarget(self, action: #selector(self.submitOrderButtonTapped(_:)), for: .touchUpInside)

        let addAddressButton = UIButton(type: .system)
        addAddressButton.titleLabel?.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        addAddressButton.setTitle("\u{f067}", for: .normal)
        addAddressButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        addAddressButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20.0)
        addAddressButton.addTarget(self, action: #selector(self.addAddressButtonTapped(_:)), for: .touchUpInside)

        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.proceedButton), UIBarButtonItem(customView: addAddressButton)]
    }
    
    func setLeftBarButton() {
        let backButton = UIButton(type: .system)
        backButton.titleLabel?.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        backButton.setTitle("\u{f30a}", for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20.0, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), for: .touchUpInside)
        
        self.editButton = UIButton(type: .system)
        self.editButton.titleLabel?.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        self.editButton.setTitle("\u{f044}", for: .normal)
        self.editButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.editButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20.0, bottom: 0, right: 0)
        self.editButton.addTarget(self, action: #selector(self.editButtonTapped(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton), UIBarButtonItem(customView: self.editButton)]
    }
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        if self.tableView.isEditing {
            self.editButton.setTitle("\u{f058}", for: .normal)
        } else {
            self.editButton.setTitle("\u{f044}", for: .normal)
        }
    }
    
    @IBAction func addAddressButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddAddressSegue", sender: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
