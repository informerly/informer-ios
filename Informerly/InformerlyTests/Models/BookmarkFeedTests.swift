//
//  BookmarkFeedTests.swift
//  Informerly
//
//  Created by Apple on 14/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class BookmarkFeedTests: XCTestCase {

    var bookmarkFeed : BookmarkFeed!
    var testData : [String:AnyObject]!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        bookmarkFeed = BookmarkFeed()
        self.createTestData()
    }
    
    
    // Helper methods
    func createTestData(){
        testData = [:]
        testData["id"] = 38150
        testData["title"] = "How CVS Quit Smoking And Grew Into A Health Care Giant"
        testData["description"] = "Michael Gaffney’s throat was scratchy for days, and lemon tea was not helping."
        testData["content"] = "Testing content of the article"
        testData["reading_time"] = 13
        testData["source"] = "NY Times"
        testData["source_color"] = "#0F0F0F"
        testData["published_at"] = "2015-07-12T23:59:27.313-04:00"
        testData["original_date"] = "2015-07-12T23:59:27.313-04:00"
        testData["shortLink"] = "http://www.nytimes.com/2015/07/12/business/how-cvs-quit-smoking-and-grew-into-a-health-care-giant.html?_r=0?curator=Informerly"
        testData["slug"] = "how-cvs-quit-smoking-and-grew-into-a-health-care-giant"
        testData["url"] = "http://www.nytimes.com/2015/07/12/business/how-cvs-quit-smoking-and-grew-into-a-health-care-giant.html?_r=0?curator=Informerly"
        testData["read"] = true
        testData["bookmarked"] = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test cases
    func testInformerlyFeedObjectIsNotNil() {
        bookmarkFeed = BookmarkFeed()
        XCTAssertNotNil(bookmarkFeed, "BookmarkFeed object is not initialized")
    }
    
    func testArticleIdPopulatedCorrectly(){
        bookmarkFeed.id = testData["id"] as? Int
        XCTAssertEqual(bookmarkFeed.id!, testData["id"] as! Int, "Artcle ID is not correctly populated")
    }
    
    func testArticleTitlePopulatedCorrectly(){
        bookmarkFeed.title = testData["title"] as? String
        XCTAssertEqual(bookmarkFeed.title!, testData["title"] as! String, "Title is not correctly populated")
    }
    
    func testDescriptionPopulatedCorrectly(){
        bookmarkFeed.feedDescription = testData["description"] as? String
        XCTAssertEqual(bookmarkFeed.feedDescription!, testData["description"] as! String, "Description is not correctly populated")
    }
    
    func testContentPopulatedCorrectly(){
        bookmarkFeed.content = testData["content"] as? String
        XCTAssertEqual(bookmarkFeed.content!, testData["content"] as! String, "Content is not correctly populated")
    }
    
    func testReadingTimePopulatedCorrectly(){
        bookmarkFeed.readingTime = testData["reading_time"] as? Int
        XCTAssertEqual(bookmarkFeed.readingTime!, testData["reading_time"] as! Int, "ReadingTime is not correctly populated")
    }
    
    func testSourcePopulatedCorrectly(){
        bookmarkFeed.source = testData["source"] as? String
        XCTAssertEqual(bookmarkFeed.source!, testData["source"] as! String, "Source is not correctly populated")
    }
    
    func testSourceColorPopulatedCorrectly(){
        bookmarkFeed.sourceColor = testData["source_color"] as? String
        XCTAssertEqual(bookmarkFeed.sourceColor!, testData["source_color"] as! String, "source_color is not correctly populated")
    }
    
    func testPublishedAtPopulatedCorrectly(){
        bookmarkFeed.publishedAt = testData["published_at"] as? String
        XCTAssertEqual(bookmarkFeed.publishedAt!, testData["published_at"] as! String, "published_at is not correctly populated")
    }
    
    func testOriginalDatePopulatedCorrectly(){
        bookmarkFeed.originalDate = testData["original_date"] as? String
        XCTAssertEqual(bookmarkFeed.originalDate!, testData["original_date"] as! String, "original_date is not correctly populated")
    }
    
    func testShortLinkPopulatedCorrectly(){
        bookmarkFeed.shortLink = testData["shortLink"] as? String
        XCTAssertEqual(bookmarkFeed.shortLink!, testData["shortLink"] as! String, "shortLink is not correctly populated")
    }
    
    func testSlugPopulatedCorrectly(){
        bookmarkFeed.slug = testData["slug"] as? String
        XCTAssertEqual(bookmarkFeed.slug!, testData["slug"] as! String, "slug is not correctly populated")
    }
    
    func testURLPopulatedCorrectly(){
        bookmarkFeed.url = testData["url"] as? String
        XCTAssertEqual(bookmarkFeed.url!, testData["url"] as! String, "url is not correctly populated")
    }
    
    func testReadPopulatedCorrectly(){
        bookmarkFeed.read = testData["read"] as? Bool
        XCTAssertEqual(bookmarkFeed.read!, testData["read"] as! Bool, "read is not correctly populated")
    }
    
    func testBookmarkedPopulatedCorrectly(){
        bookmarkFeed.bookmarked = testData["bookmarked"] as? Bool
        XCTAssertEqual(bookmarkFeed.bookmarked!, testData["bookmarked"] as! Bool, "bookmarked is not correctly populated")
    }
    
    func testIsSyncPopulatedCorrectly() {
        bookmarkFeed.isSynced = true
        XCTAssertEqual(bookmarkFeed.isSynced!, true, "isSynced is not populated correctly.")
    }


}
