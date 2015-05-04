//
//  Bookmarks.swift
//  Informerly
//
//  Created by Apple on 02/05/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class Bookmarks {
    
    private var bookmarks : [InformerlyFeed] = []
    class var sharedInstance :Bookmarks {
        struct Singleton {
            static let instance = Bookmarks()
        }
        
        return Singleton.instance
    }
    
    func populateFeeds(feeds : [AnyObject]) {
        self.bookmarks.removeAll(keepCapacity: false)
        for feedData in feeds {
            var feed : InformerlyFeed = InformerlyFeed()
            feed.populateFeed(feedData as! [String: AnyObject])
            
            self.bookmarks.append(feed)
        }
    }
    
    func getBookmarks()->[InformerlyFeed]! {
        return bookmarks
    }
    
    func addBookmark(feed : InformerlyFeed){
        bookmarks.insert(feed, atIndex: 0)
    }
    
    func removeBookmark(feedID : Int) {
        var counter = 0
        for feed in bookmarks {
            if feed.id == feedID {
                self.bookmarks.removeAtIndex(counter)
                break
            }
            counter++
        }
    }
}