//
//  feeds.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class Feeds  {
    
    private var feeds : [InformerlyFeed] = []
    class var sharedInstance :Feeds {
        struct Singleton {
            static let instance = Feeds()
        }
        
        return Singleton.instance
    }
    
    func populateFeeds(feeds : [AnyObject]) {
        self.feeds.removeAll(keepCapacity: false)
        for feedData in feeds {
            var feed : InformerlyFeed = InformerlyFeed()
            feed.populateFeed(feedData as! [String: AnyObject])
            
            self.feeds.append(feed)
        }
    }
    
    func getFeeds()->[InformerlyFeed]! {
        return feeds
    }
}