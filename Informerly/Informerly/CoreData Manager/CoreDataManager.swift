//
//  CoreDataManager.swift
//  Informerly
//
//  Created by Apple on 05/05/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager
{
    class func addBookmarkFeeds(feedList: [AnyObject], isSynced: Bool) {
        self.removeAllBookmarkFeeds()
        for feed in feedList {
            self.addFeed(feed as! [String : AnyObject], isSynced: isSynced)
        }
    }
    
    class func addFeed(feedDict:[String:AnyObject], isSynced: Bool) {
        
//        if (self.isFeedAlreadyExistForFeedID(feedDict["id"] as! Int)) {
//            return
//        }
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var feedItem : BookmarkEntity = NSEntityDescription.insertNewObjectForEntityForName("BookmarkEntity", inManagedObjectContext: managedContext) as! BookmarkEntity
        
        feedItem.id = feedDict["id"] as? Int
        feedItem.title = feedDict["title"] as? String
        feedItem.feedDescription = feedDict["description"] as? String
        feedItem.content = feedDict["content"] as? String
        feedItem.readingTime = feedDict["reading_time"] as? Int
        feedItem.source = feedDict["source"] as? String
        feedItem.sourceColor = feedDict["source_color"] as? String
        feedItem.publishedAt = feedDict["published_at"] as? String
        feedItem.originalDate = feedDict["original_date"] as? String
        feedItem.shortLink = feedDict["shortLink"] as? String
        feedItem.slug = feedDict["slug"] as? String
        feedItem.url = feedDict["url"] as? String
        feedItem.read = feedDict["read"] as? Bool
        feedItem.bookmarked = feedDict["bookmarked"] as? Bool
        feedItem.isSynced = isSynced
        feedItem.creationDateTime = NSDate()
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    class func addBookmarkFeed(feed:InformerlyFeed, isSynced: Bool) {
        
        if (self.isFeedAlreadyExistForFeedID(feed.id!)) {
            return
        }
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var feedItem : BookmarkEntity = NSEntityDescription.insertNewObjectForEntityForName("BookmarkEntity", inManagedObjectContext: managedContext) as! BookmarkEntity
        
        feedItem.id = feed.id
        feedItem.title = feed.title
        feedItem.feedDescription = feed.feedDescription
        feedItem.content = feed.content
        feedItem.readingTime = feed.readingTime
        feedItem.source = feed.source
        feedItem.sourceColor = feed.sourceColor
        feedItem.publishedAt = feed.publishedAt
        feedItem.originalDate = feed.originalDate
        feedItem.shortLink = feed.shortLink
        feedItem.slug = feed.slug
        feedItem.url = feed.URL
        feedItem.read = feed.read
        feedItem.bookmarked = feed.bookmarked
        feedItem.isSynced = isSynced
        feedItem.creationDateTime = NSDate()
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    class func addBookmarkFeed(feed:BookmarkFeed, isSynced: Bool) {
        
        if (self.isFeedAlreadyExistForFeedID(feed.id!)) {
            return
        }
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var feedItem : BookmarkEntity = NSEntityDescription.insertNewObjectForEntityForName("BookmarkEntity", inManagedObjectContext: managedContext) as! BookmarkEntity
        
        feedItem.id = feed.id
        feedItem.title = feed.title
        feedItem.feedDescription = feed.feedDescription
        feedItem.content = feed.content
        feedItem.readingTime = feed.readingTime
        feedItem.source = feed.source
        feedItem.sourceColor = feed.sourceColor
        feedItem.publishedAt = feed.publishedAt
        feedItem.originalDate = feed.originalDate
        feedItem.shortLink = feed.shortLink
        feedItem.slug = feed.slug
        feedItem.url = feed.url
        feedItem.read = feed.read
        feedItem.bookmarked = feed.bookmarked
        feedItem.isSynced = isSynced
        feedItem.creationDateTime = NSDate()
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    class func getBookmarkFeeds() -> [BookmarkFeed] {
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var request: NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("BookmarkEntity", inManagedObjectContext: managedContext)
        request.sortDescriptors = [NSSortDescriptor(key: "creationDateTime", ascending: false)]
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkEntity]
        
        if(error != nil) {
            println("Error in fetching Bookmarks \(error), \(error?.userInfo)")
        }
        
        var bookmarkFeeds : [BookmarkFeed] = []
        for feed in result {
            var bookmarkfeed : BookmarkFeed = BookmarkFeed()
            bookmarkfeed.populateBookmarkFeed(feed)
            bookmarkFeeds.append(bookmarkfeed)
        }
        
        return bookmarkFeeds
    }
    
    class func removeBookmarkFeedOfID(feedID: Int) {
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var request: NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("BookmarkEntity", inManagedObjectContext: managedContext)
        request.predicate = NSPredicate(format: "id=\(feedID)", argumentArray: nil)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkEntity]
        
        if(error == nil) {
            if result.count > 0 {
                managedContext.deleteObject(result[0])
                managedContext.save(nil)
            }
        }
        else {
            println("Error in fetching Bookmarks \(error), \(error?.userInfo)")
        }
    }
    
    class func removeAllBookmarkFeeds() {
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var request: NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("BookmarkEntity", inManagedObjectContext: managedContext)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkEntity]
        
        if(error == nil) {
            if result.count > 0 {
                for feedItem in result {
                    managedContext.deleteObject(feedItem)
                }
                managedContext.save(nil)
            }
        }
        else {
            println("Error in fetching Bookmarks \(error), \(error?.userInfo)")
        }
    }
    
    class func updateSyncStatusForFeedID(feedID: Int, syncStatus:Bool) {
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var request: NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("BookmarkEntity", inManagedObjectContext: managedContext)
        request.predicate = NSPredicate(format: "id=\(feedID)", argumentArray: nil)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkEntity]
        
        if(error == nil) {
            var bookmarkFeed: BookmarkEntity = result[0] as BookmarkEntity
            bookmarkFeed.isSynced = syncStatus
            managedContext.save(nil)
        }
        else {
            println("Error in fetching Bookmarks \(error), \(error?.userInfo)")
        }
    }
    
    class func updateReadStatusForFeedID(feedID: Int, readStatus:Bool) {
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var request: NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("BookmarkEntity", inManagedObjectContext: managedContext)
        request.predicate = NSPredicate(format: "id=\(feedID)", argumentArray: nil)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkEntity]
        
        if(error == nil) {
            var bookmarkFeed: BookmarkEntity = result[0] as BookmarkEntity
            bookmarkFeed.isSynced = readStatus
            managedContext.save(nil)
        }
        else {
            println("Error in fetching Bookmarks \(error), \(error?.userInfo)")
        }
    }
    
    class func isFeedAlreadyExistForFeedID (feedID: Int) -> Bool {
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var request: NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("BookmarkEntity", inManagedObjectContext: managedContext)
        request.predicate = NSPredicate(format: "id=\(feedID)", argumentArray: nil)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkEntity]
        if(error == nil) {
            if (result.count == 1) {
                return true
            }
        }
        else {
            println("Error in fetching Bookmarks \(error), \(error?.userInfo)")
        }
        
        return false
    }
}
