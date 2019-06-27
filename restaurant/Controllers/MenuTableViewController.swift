//
//  MenuTableViewController.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    var category: String?
    var menuItems = [MenuItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.category?.capitalized
        tableView.register(UINib(nibName: "MenuItemTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuItemTableViewCell")
        
        self.setBarButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: MenuService.menuItemsUpdatedNotification, object: nil)
        
        self.updateUI()
        
    }
    
    @objc func updateUI() {
        guard let category = category else {return}
        self.menuItems = MenuService.shared.getMenuItemsByCategory(category: category) ?? []
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.menuItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell", for:
            indexPath) as! MenuItemTableViewCell

        let item = self.menuItems[indexPath.row]
        cell.itemTitleLabel?.text = item.name
        cell.itemPriceLabel?.text = String(format: "$%.2f", item.price)
        cell.itemImageView.layer.cornerRadius = 7
        
        let imageURL = URL(string: item.imageURL)!
        MenuService.shared.fetchImage(for: imageURL) {
            (image) in
            guard let image = image else {return}
            
            DispatchQueue.main.async {
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath != indexPath {
                    return
                }
                
                cell.itemImageView?.image = image
                cell.setNeedsLayout()
            }
        }

        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MenuSegueIdentifier" {
            let menuDetailViewController = segue.destination as! MenuDetailViewController
            let index = tableView.indexPathForSelectedRow!.row
            menuDetailViewController.item = self.menuItems[index]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        guard let category = category else {
            return
        }
        coder.encode(category, forKey: "category")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        self.category = (coder.decodeObject(forKey: "category") as! String)
        self.updateUI()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MenuSegueIdentifier", sender: nil)
    }
    
    func setBarButtons() {
        self.setLeftBarButton()
    }
    
    func setLeftBarButton() {
        let backButton = UIButton(type: .system)
        backButton.titleLabel?.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        backButton.setTitle("\u{f30a}", for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20.0, bottom: 0, right: 0)
        backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), for: .touchUpInside)
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
