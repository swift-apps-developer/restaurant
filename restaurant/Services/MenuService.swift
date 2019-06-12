//
//  MenuService.swift
//  restaurant
//
//  Created by love on 5/18/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import UIKit

class MenuService {
    static let shared = MenuService()
    private var menuItemById = [Int: MenuItem]()
    private var menuItemByCategory = [String: [MenuItem]]()
    
    var categories: [String] {
        get {
            return Array<String>(self.menuItemByCategory.keys.sorted())
        }
    }

    static let orderUpdatedNotification = Notification.Name("MenuService.orderUpdated")
    static let menuItemsUpdatedNotification = Notification.Name("MenuService.menuItemsUpdated")
    
    static let orderIsReadyNotification = Notification.Name("MenuService.orderIsReady")
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuService.orderUpdatedNotification, object: nil)
        }
    }

    let baseURL = URL(string: "http://localhost:8090/")
    
    func getMenuItemById(id: Int) -> MenuItem? {
        return self.menuItemById[id]
    }
    
    func getMenuItemsByCategory(category: String) -> [MenuItem]? {
        return self.menuItemByCategory[category]
    }
    
    
    
    func fetchCategories(completionHandler: @escaping ([String]?) -> Void) {
        let url = self.baseURL?.appendingPathComponent("categories")
        
        let dataTask = URLSession.shared.dataTask(with: url!) {
            (data, error, response) in
            
            if let data = data, let jsonCategoryResult = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let categories = jsonCategoryResult?["categories"] as? [String] {
                completionHandler(categories)
            }
            else {
                completionHandler(nil)
            }
        }
        
        dataTask.resume()
    }
    
    func fetchMenuItems(forCategory category: String, completionHandler: @escaping ([MenuItem]?) -> Void){
        let url = self.baseURL?.appendingPathComponent("menu")
        var urlComponent = URLComponents(url: url!, resolvingAgainstBaseURL: true)!
        urlComponent.queryItems = [URLQueryItem(name: "category", value: category)]
        let menuURL = urlComponent.url!
        
        let dataTask = URLSession.shared.dataTask(with: menuURL) {
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            
            if let data = data, let result = try? jsonDecoder.decode(MenuItems.self, from: data) {
                completionHandler(result.items)
            }
            else {
                completionHandler(nil)
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
    
    func loadOrder() {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let orderFileURL = documentDirectoryURL.appendingPathComponent("order").appendingPathExtension("json")
        guard let data = try? Data(contentsOf: orderFileURL) else {return}
        let jsonDecoder = JSONDecoder()
        self.order = (try? jsonDecoder.decode(Order.self, from: data)) ?? Order()
    }
    
    func saveOrder() {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let orderFileURL = documentDirectoryURL.appendingPathComponent("order").appendingPathExtension("json")
        
        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(self.order) {
            try? data.write(to: orderFileURL)
        }
    }
    
    private func process(_ menuItems: [MenuItem]) {
        self.menuItemById.removeAll()
        self.menuItemByCategory.removeAll()
        
        for item in menuItems {
            self.menuItemById[item.id] = item
            self.menuItemByCategory[item.category, default: []].append(item)
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: MenuService.menuItemsUpdatedNotification, object: nil)
        }
    }
    
    func loadRemoteData() {
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
    
    func saveItems() {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let itemsFileURL = documentDirectoryURL.appendingPathComponent("menuItems").appendingPathExtension("json")
        
        let items = Array(self.menuItemById.values)
        
        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(items) {
            try? data.write(to: itemsFileURL)
        }
    }
    
    func loadItems() {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let itemsFileURL = documentDirectoryURL.appendingPathComponent("menuItems").appendingPathExtension("json")
        
        if let data = try? Data(contentsOf: itemsFileURL) {
            let jsonDecoder = JSONDecoder()
            if let menuItems = try? jsonDecoder.decode([MenuItem].self, from: data) {
                self.process(menuItems)
            }
            else {
                self.process([])
            }
        }
    }
}
