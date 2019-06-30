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
    static let addressesUpdatedNotification = Notification.Name("MenuService.addressesUpdated")
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
    
    func getCategories() -> [Category] {
        let realm = try! Realm()
        return Array(realm.objects(Category.self))
    }
    
    func getAddresses() -> [Address] {
        let realm = try! Realm()
        return Array(realm.objects(Address.self).sorted(byKeyPath: "createdDate", ascending: false))
    }
    
    func fetchCategories() {
        let url = self.baseURL?.appendingPathComponent("categories")
        
        let dataTask = URLSession.shared.dataTask(with: url!) { [unowned self]
            (data, response, error) in
            
            guard self.handleError(data: data, response: response, error: error) else {
                return
            }
            
            guard let data = data,
                  let jsonCategoryResult = try? JSONSerialization.jsonObject(with: data),
                  let categories = jsonCategoryResult as? [String: Any],
                  let categoryList = categories["categories"] as? [String]
            else {
                NotificationCenter.default.post(name: AlertService.infoAlertNotification, object: nil, userInfo: ["title": Messages.invalidJsonErrorTitle, "message": String.init(format: Messages.invalidJsonErrorMessage, "Categories")])
                return
            }
            
            self.storeCategories(categoryList)
            self.fetchMenuItems()
           
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
        
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { [unowned self]
            (data, response, error) in
            
            guard self.handleError(data: data, response: response, error: error) else {
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            guard let data = data, let result = try? jsonDecoder.decode(PreparationTime.self, from: data) else {
                NotificationCenter.default.post(name: AlertService.infoAlertNotification, object: nil, userInfo: ["title": Messages.invalidJsonErrorTitle, "message": String.init(format: Messages.invalidJsonErrorMessage, "Submit Order")])
                return
            }
            
            completionHander(result.prepareTime)

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
        
        let dataTask = URLSession.shared.dataTask(with: menuURL){ [unowned self]
            (data, response, error) in
            
            guard self.handleError(data: data, response: response, error: error) else {
                return
            }
            
            let jsonDecoder = JSONDecoder()
            guard let data = data, let menuItems = try? jsonDecoder.decode(MenuItems.self, from: data) else {
                NotificationCenter.default.post(name: AlertService.infoAlertNotification, object: nil, userInfo: ["title": Messages.invalidJsonErrorTitle, "message": String.init(format: Messages.invalidJsonErrorMessage, "Menu Item")])
                return
            }
            
            self.process(menuItems.items)

        }
        dataTask.resume()
    }
    
    func handleError(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        guard error == nil else {
            NotificationCenter.default.post(name: AlertService.infoAlertNotification, object: nil, userInfo: ["title": Messages.serverErrorTitle, "message": error!.localizedDescription])
            return false
        }
        
        if let response = response {
            switch (response as! HTTPURLResponse).statusCode {
            case 400..<500:
                var message = Messages.badRequestErrorMessage
                if let data = data, let jsonError = try? JSONSerialization.jsonObject(with: data), let errorResult = jsonError as? [String: Any] {
                    message = (errorResult["detail"] as? String) ?? message
                }
                NotificationCenter.default.post(name: AlertService.infoAlertNotification, object: nil, userInfo: ["title": Messages.badRequestErrorTitle, "message": message])
                return false
            case 500..<600:
                var message = Messages.serverErrorMessage
                if let data = data, let jsonError = try? JSONSerialization.jsonObject(with: data), let errorResult = jsonError as? [String: Any] {
                    message = (errorResult["detail"] as? String) ?? message
                }
                NotificationCenter.default.post(name: AlertService.infoAlertNotification, object: nil, userInfo: ["title": Messages.serverErrorTitle, "message": Messages.serverErrorMessage])
                return false
            default:
                break
            }
        }
        return true
    }
    
    func storeCategories(_ categories: [String]) {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
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
    
    func resetDefaultAddress() {
        let realm = try! Realm()
        
        let defaultAddressResult = realm.objects(Address.self).filter("isDefault=true")
        
        if defaultAddressResult.count < 1 {
            return
        }
        
        let defaultAddress = defaultAddressResult[0]
        try! realm.write {
            defaultAddress.isDefault = false
        }
    }
    
    func setDefaultAddress(for address: Address) {
        self.resetDefaultAddress()
        let realm = try! Realm()
        
        try! realm.write {
            address.isDefault = true
        }
        
        NotificationCenter.default.post(name: MenuService.addressesUpdatedNotification, object: nil)
    }
    
    func removeAddress(_ address: Address) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(address)
        }
        
        NotificationCenter.default.post(name: MenuService.addressesUpdatedNotification, object: nil)
    }
    
    func saveAddress(with address: Address) {
        self.resetDefaultAddress()
        let realm = try! Realm()
        
        if address.id == 0 {
            let id = realm.objects(Address.self).sorted(byKeyPath: "id").last?.id ?? 0
            address.id = id + 1
        }
        
        try! realm.write {
            realm.add(address, update: .modified)
        }
        
        NotificationCenter.default.post(name: MenuService.addressesUpdatedNotification, object: nil)
    }
    
    func setAddressForOrder(_ defaultAddress: Address) {
        let realm = try! Realm()
        let order = self.getLatestOrder()!
        
        try! realm.write {
            order.address = defaultAddress
        }
        
        self.createNewOrder()
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
