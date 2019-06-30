//
//  Messages.swift
//  restaurant
//
//  Created by love on 6/30/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation


struct Messages {
    static let serverErrorTitle = "Server Error"
    static let serverErrorMessage = "The server encountered an internal error"
    
    static let invalidJsonErrorTitle = "Invalid JSON Data"
    static let invalidJsonErrorMessage = "Please check the json data for %@"
    
    static let badRequestErrorTitle = "Bad Request"
    static let badRequestErrorMessage = "Bad request error"
    
    static let categoryIsRequiredErrorTitle = "Category Is Required"
    static let categoryIsRequiredErrorMessage = "Please select a category from restaurant menu"
    
    static let menuItemNotFoundErrorTitle = "MenuItem Not Found"
    static let menuItemNotFoundErrorMessage = "Menu item not found"
    
    static let validationErrorTitle = "Validation error"
    
    static let cartIsEmptyErrorTitle = "Cart Is Empty"
    static let cartIsEmptyErrorMessage = "Please add at least one item to your order"
}
