//
//  CategoryFeed.swift
//  Informerly
//
//  Created by Apple on 13/05/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
class CategoryFeeds {
    
    private var feeds : [InformerlyFeed] = []
    private var categoriesData : [Int:[InformerlyFeed]] = [:]
    class var sharedInstance : CategoryFeeds {
        struct Singleton {
            static let instance = CategoryFeeds()
        }
        
        return Singleton.instance
    }
    
    func populateFeeds(feeds : [AnyObject], categoryID : Int) {
        self.feeds.removeAll(keepCapacity: false)
        
        var newItems : [AnyObject] = []
        
        if feeds.count > 20 {
            
            for (var i = 0; i < 20; i++) {
                var feed : AnyObject = feeds[i]
                newItems.append(feed)
            }
            
            for feedData in newItems {
                var feed : InformerlyFeed = InformerlyFeed()
                feed.populateFeed(feedData as! [String: AnyObject])
                
                self.feeds.append(feed)
            }
        } else {
            for feedData in feeds {
                var feed : InformerlyFeed = InformerlyFeed()
                feed.populateFeed(feedData as! [String: AnyObject])
                
                self.feeds.append(feed)
            }
        }
        
        self.categoriesData[categoryID] = self.feeds
    }
    
    func getCategoryFeeds(CategoryID : Int)->[InformerlyFeed]? {
        return self.categoriesData[CategoryID]
    }
    
}
