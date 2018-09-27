//
//  Product.swift
//  TaskTrackr
//
//  Created by Eric Ho on 4/09/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import RealmSwift

class Model: Object {
    
    @objc dynamic var modelId: String = UUID().uuidString
    @objc dynamic var modelName: String?
    @objc dynamic var product: Product?
    
    override static func primaryKey() -> String? {
        return "modelId"
    }
    
}

class Product: Object {
    
    // Auto Id
    @objc dynamic var productId: String = UUID().uuidString
    // Product Name
    @objc dynamic var productName: String?
    // Product Description
    @objc dynamic var productDesc: String?
    // Created Date
    @objc dynamic var timestamp: Date = Date()
    
    // Primary Key
    override static func primaryKey() -> String {
        return "productId"
    }
}
