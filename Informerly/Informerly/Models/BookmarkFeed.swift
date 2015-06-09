//
//  BookmarkFeed.swift
//  Informerly
//
//  Created by Apple on 09/06/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class BookmarkFeed {
    var id : Int?
    var title : String?
    var feedDescription : String?
    var content : String?
    var readingTime : Int?
    var source : String?
    var sourceColor : String?
    var publishedAt : String?
    var originalDate : String?
    var shortLink : String?
    var slug : String?
    var url : String?
    var read : Bool?
    var bookmarked : Bool?
    var isSynced : NSNumber?
    
    init(){}
    
    func populateBookmarkFeed (feed:BookmarkEntity) {
        self.id = feed.id?.integerValue
        self.title = feed.title
        self.feedDescription = feed.feedDescription
        self.content = feed.content
        self.readingTime = feed.readingTime?.integerValue
        self.source = feed.source
        self.sourceColor = feed.sourceColor
        self.publishedAt = feed.publishedAt
        self.originalDate = feed.originalDate
        self.shortLink = feed.shortLink
        self.slug = feed.slug
        self.url = feed.url
        self.read = feed.read?.boolValue
        self.bookmarked = feed.bookmarked?.boolValue
        self.isSynced = feed.isSynced
    }
}
