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
    class func addBookmarkFeed(feedDict:[String:AnyObject], isSynced: Bool) {
        
        if (self.isFeedAlreadyExistForFeedID(feedDict["id"] as! Int)) {
            return
        }
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var feedItem : BookmarkFeed = NSEntityDescription.insertNewObjectForEntityForName("BookmarkFeed", inManagedObjectContext: managedContext) as! BookmarkFeed
        
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
        request.entity = NSEntityDescription.entityForName("BookmarkFeed", inManagedObjectContext: managedContext)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkFeed]
        
        if(error != nil) {
            println("Error in fetching Bookmarks \(error), \(error?.userInfo)")
        }
        
        return result;
    }
    
    class func removeBookmarkFeedOfID(feedID: Int) {
        
        //create the object of AppDelegate
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //get the context from AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var request: NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("BookmarkFeed", inManagedObjectContext: managedContext)
        request.predicate = NSPredicate(format: "id=\(feedID)", argumentArray: nil)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkFeed]
        
        if(error == nil) {
            managedContext.deleteObject(result[0])
            managedContext.save(nil)
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
        request.entity = NSEntityDescription.entityForName("BookmarkFeed", inManagedObjectContext: managedContext)
        request.predicate = NSPredicate(format: "id=\(feedID)", argumentArray: nil)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkFeed]
        
        if(error == nil) {
            var bookmarkFeed: BookmarkFeed = result[0] as BookmarkFeed
            bookmarkFeed.isSynced = syncStatus
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
        request.entity = NSEntityDescription.entityForName("BookmarkFeed", inManagedObjectContext: managedContext)
        request.predicate = NSPredicate(format: "id=\(feedID)", argumentArray: nil)
        
        var error: NSError?
        var result: Array = managedContext.executeFetchRequest(request, error: &error) as! [BookmarkFeed]
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
