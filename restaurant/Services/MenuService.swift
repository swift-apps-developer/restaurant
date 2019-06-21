//
//  MenuService.swift
//  restaurant
//
//  Created by love on 5/18/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class MenuService {
    static let shared = MenuService()
    var token : NotificationToken?

    static let orderUpdatedNotification = Notification.Name("MenuService.orderUpdated")
    static let menuItemsUpdatedNotification = Notification.Name("MenuService.menuItemsUpdated")
    
    static let orderIsReadyNotification = Notification.Name("MenuService.orderIsReady")

    let baseURL = URL(string: "http://localhost:8090/")
    
    func getMenuItemById(id: Int) -> MenuItem? {
        let realm = try! Realm()
        return realm.object(ofType: MenuItem.self, forPrimaryKey: id)
    }
    
    func getMenuItemsByCategory(category: String) -> [MenuItem]? {
        let realm = try! Realm()
        return Array(realm.objects(MenuItem.self).filter("category = '\(category)'"))
    }
    
    func getCategories() -> [Category]? {
        let realm = try! Realm()
        return Array(realm.objects(Category.self))
    }
    
    func fetchCategories() {
        let url = self.baseURL?.appendingPathComponent("categories")
        
        let dataTask = URLSession.shared.dataTask(with: url!) {
            (data, error, response) in
            
            if let data = data, let jsonCategoryResult = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let categories = jsonCategoryResult?["categories"] as? [String] {
                self.storeCategories(categories)
                self.fetchMenuItems()
            }
            else {
                self.storeCategories([])
            }
        }
        
        dataTask.resume()
    }
    
    func sumitOrderWith(menuIDs ids: [Int], completionHander: @escaping (Int?) -> Void) {
        let url = self.baseURL?.appendingPathComponent("order")
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: [Int]] = ["menuIds": ids]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        
        urlRequest.httpBody = jsonData
        
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            let jsonDecoder = JSONDecoder()
            if let data = data, let result = try? jsonDecoder.decode(PreparationTime.self, from: data) {
                completionHander(result.prepareTime)
            }
            else {
                completionHander(nil)
            }
        }
        
        dataTask.resume()
    }
    
    func fetchImage(for url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completionHandler(image)
            } else {
                completionHandler(nil)
            }
        }
        
        dataTask.resume()
    }
    
    private func process(_ menuItems: [MenuItem]) {
        let realm = try! Realm()
        
        for item in menuItems {
            try! realm.write {
                realm.add(item, update: .modified)
            }
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: MenuService.menuItemsUpdatedNotification, object: nil)
        }
    }
    
    func fetchMenuItems() {
        let url = self.baseURL?.appendingPathComponent("menu")
        let urlComponent = URLComponents(url: url!, resolvingAgainstBaseURL: true)!
        let menuURL = urlComponent.url!
        
        let dataTask = URLSession.shared.dataTask(with: menuURL){
            (data, _, _) in
            let jsonDecoder = JSONDecoder()
            
            if let data = data, let menuItems = try? jsonDecoder.decode(MenuItems.self, from: data) {
                self.process(menuItems.items)
            }
            else {
                self.process([])
            }
        }
        dataTask.resume()
    }
    
    func storeCategories(_ categories: [String]) {
        let realm = try! Realm()
        
        for (index, item) in categories.enumerated() {
            let result = realm.objects(Category.self).filter("name = '\(item)'")
            if result.count == 0 {
                try! realm.write {
                    realm.create(Category.self, value: ["id": index, "name": item])
                }
            }
        }
    }
    
    func addToOrder(menuItem: MenuItem, count: Int = 1) {
        if let order = getLatestOrder() {
            let realm = try! Realm()
            
            var item = order.items.filter("menuItem.id = \(menuItem.id)").first
            
            if let item = item {
                try! realm.write {
                    item.count += 1
                }
            } else {
                item = OrderItem(menuItem: menuItem)
                let id = realm.objects(OrderItem.self).sorted(byKeyPath: "id").last?.id ?? 0
                
                item?.id = id + 1
                try! realm.write {
                    order.items.append(item!)
                }
            }
        } else {
            createNewOrder()
            self.addToOrder(menuItem: menuItem)
        }

    }
    
    func createNewOrder() {
        let realm = try! Realm()
        let order = Order()
        self.token = nil
        
        let id = realm.objects(Order.self).sorted(byKeyPath: "id").last?.id ?? 0
        order.id = id + 1
        
        order.name = order.generateName()

        try! realm.write {
            realm.add(order)
        }
        
        self.setOrderNotification(order)
    }
    
    func getLatestOrder() -> Order? {
        let realm = try! Realm()
        let order = realm.objects(Order.self).sorted(byKeyPath: "createdDate").last
        self.setOrderNotification(order)
        return order
    }
    
    func setOrderNotification(_ order: Order?) {
        if let order = order, token == nil {
            token = order.items.observe { change in
                switch change {
                case .initial:
                    NotificationCenter.default.post(name: MenuService.orderUpdatedNotification, object: nil)
                case .update:
                    NotificationCenter.default.post(name: MenuService.orderUpdatedNotification, object: nil)
                case .error(let error):
                    print("An error occurred: \(error)")
                }
            }
        }
    }
    
    func removeOrderItem(orderItemId: Int) {
        guard let order = self.getLatestOrder() else {
            return
        }
        
        let realm = try! Realm()
        
        let item = order.items.filter("id = \(orderItemId)").first
        
        if let item = item {
            try! realm.write {
                realm.delete(item)
            }
        }
    }
}
