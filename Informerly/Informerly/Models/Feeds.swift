//
//  feeds.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class Feeds  {
    
    class InformerlyFeed {
        
        var id : Int?
        var title : String?
        var description : String?
        var content : String?
        var readingTime : Int?
        var source : String?
        var publishedAt : String?
        var originalDate : String?
        var shortLink : String?
        var slug : String?
        var URL : String?
        var read : Bool?
        var bookmarked : Bool?
        
        init(){}
        
        func populateFeed (feed:[String:AnyObject]) {
            self.id = feed["id"] as? Int
            self.title = feed["title"] as? String
            self.description = feed["description"] as? String
            self.content = feed["content"] as? String
            self.readingTime = feed["reading_time"] as? Int
            self.source = feed["source"] as? String
            self.publishedAt = feed["published_at"] as? String
            self.originalDate = feed["original_date"] as? String
            self.shortLink = feed["shortLink"] as? String
            self.slug = feed["slug"] as? String
            self.URL = feed["url"] as? String
            self.read = feed["read"] as? Bool
            self.bookmarked = feed["bookmarked"] as? Bool
        }
        
    }
    
    
    private var feeds : [InformerlyFeed] = []
    class var sharedInstance :Feeds {
        struct Singleton {
            static let instance = Feeds()
        }
        
        return Singleton.instance
    }
    
    func populateFeeds(feeds : [AnyObject]) {
        for feedData in feeds {
            var feed : InformerlyFeed = InformerlyFeed()
            feed.populateFeed(feedData as [String: AnyObject])
            
            self.feeds.append(feed)
        }
    }
    
    func getFeeds()->[InformerlyFeed]! {
        return feeds
    }
}