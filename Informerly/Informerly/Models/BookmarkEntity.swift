//
//  BookmarkFeed.swift
//  Informerly
//
//  Created by Apple on 19/05/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import CoreData

@objc(BookmarkEntity)

class BookmarkEntity: NSManagedObject {

    @NSManaged var bookmarked: NSNumber?
    @NSManaged var content: String?
    @NSManaged var feedDescription: String?
    @NSManaged var id: NSNumber?
    @NSManaged var isSynced: NSNumber?
    @NSManaged var originalDate: String?
    @NSManaged var publishedAt: String?
    @NSManaged var read: NSNumber?
    @NSManaged var readingTime: NSNumber?
    @NSManaged var shortLink: String?
    @NSManaged var slug: String?
    @NSManaged var source: String?
    @NSManaged var sourceColor: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var creationDateTime: NSDate?

}
