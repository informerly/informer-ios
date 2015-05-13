//
//  Item.swift
//  Informerly
//
//  Created by Apple on 12/05/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class Item {
    var id : Int?
    var magic : String?
    var name : String?
    var primary : Int?
    var user_id : Int?
    
    init(){}
    
    func populateItem (item:[String:AnyObject]) {
        self.id = item["id"] as? Int
        self.magic = item["magic"] as? String
        self.name = item["name"] as? String
        self.primary = item["primary"] as? Int
        self.user_id = item [""] as? Int
    }
}