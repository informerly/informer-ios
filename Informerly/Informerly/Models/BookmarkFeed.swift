//
//  BookmarkFeed.swift
//  Informerly
//
//  Created by Muhammad Junaid Butt on 08/05/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import CoreData

@objc(BookmarkFeed)

class BookmarkFeed: NSManagedObject {

    @NSManaged var id: NSNumber?
    @NSManaged var title: String?
    @NSManaged var feedDescription: String?
    @NSManaged var content: String?
    @NSManaged var readingTime: NSNumber?
    @NSManaged var source: String?
    @NSManaged var sourceColor: String?
    @NSManaged var publishedAt: String?
    @NSManaged var originalDate: String?
    @NSManaged var shortLink: String?
    @NSManaged var slug: String?
    @NSManaged var url: String?
    @NSManaged var read: NSNumber?
    @NSManaged var bookmarked: NSNumber?
    @NSManaged var isSynced: NSNumber?

}
