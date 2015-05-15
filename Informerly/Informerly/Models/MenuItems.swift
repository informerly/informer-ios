//
//  MenuFeeds.swift
//  Informerly
//
//  Created by Apple on 12/05/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class MenuItems {
    private var items : [Item] = []
    class var sharedInstance : MenuItems {
        struct Singleton {
            static let instance = MenuItems()
        }
        
        return Singleton.instance
    }
    
    func populateItems(items : [AnyObject]) {
        self.items.removeAll(keepCapacity: false)
        
        for itemData in items {
            var item : Item = Item()
            item.populateItem(itemData as! [String: AnyObject])
            
            self.items.append(item)
        }
    }
    
    func getItems()->[Item]! {
        return items
    }
}