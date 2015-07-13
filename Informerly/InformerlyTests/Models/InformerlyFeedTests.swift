//
//  InformerlyFeedTests.swift
//  Informerly
//
//  Created by Apple on 13/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class InformerlyFeedTests: XCTestCase {

    var feed : InformerlyFeed!
    var testData : [String:AnyObject]!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        feed = InformerlyFeed()
        self.createTestData()
    }
    
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
    
    func testInformerlyFeedObjectIsNotNil() {
        feed = InformerlyFeed()
        XCTAssertNotNil(feed, "Feed object is not initialized")
    }
    
    func testArticleIdPopulatedCorrectly(){
        feed.id = testData["id"] as? Int
        XCTAssertEqual(feed.id!, testData["id"] as! Int, "Artcle ID is not correctly populated")
    }
    
    func testArticleTitlePopulatedCorrectly(){
        feed.title = testData["title"] as? String
        XCTAssertEqual(feed.title!, testData["title"] as! String, "Title is not correctly populated")
    }
    
    func testDescriptionPopultedCorrectly(){
        feed.feedDescription = testData["description"] as? String
        XCTAssertEqual(feed.feedDescription!, testData["description"] as! String, "Description is not correctly populated")
    }
    
    func testContentPopultedCorrectly(){
        feed.content = testData["content"] as? String
        XCTAssertEqual(feed.content!, testData["content"] as! String, "Content is not correctly populated")
    }
    
    func testReadingTimePopultedCorrectly(){
        feed.readingTime = testData["reading_time"] as? Int
        XCTAssertEqual(feed.readingTime!, testData["reading_time"] as! Int, "ReadingTime is not correctly populated")
    }
    
    func testSourcePopultedCorrectly(){
        feed.source = testData["source"] as? String
        XCTAssertEqual(feed.source!, testData["source"] as! String, "Source is not correctly populated")
    }
    
    func testSourceColorPopultedCorrectly(){
        feed.sourceColor = testData["source_color"] as? String
        XCTAssertEqual(feed.sourceColor!, testData["source_color"] as! String, "source_color is not correctly populated")
    }
    
    func testPublishedAtPopultedCorrectly(){
        feed.publishedAt = testData["published_at"] as? String
        XCTAssertEqual(feed.publishedAt!, testData["published_at"] as! String, "published_at is not correctly populated")
    }

    func testOriginalDatePopultedCorrectly(){
        feed.originalDate = testData["original_date"] as? String
        XCTAssertEqual(feed.originalDate!, testData["original_date"] as! String, "original_date is not correctly populated")
    }
    
    func testShortLinkPopultedCorrectly(){
        feed.shortLink = testData["shortLink"] as? String
        XCTAssertEqual(feed.shortLink!, testData["shortLink"] as! String, "shortLink is not correctly populated")
    }
    
    func testSlugPopultedCorrectly(){
        feed.slug = testData["slug"] as? String
        XCTAssertEqual(feed.slug!, testData["slug"] as! String, "slug is not correctly populated")
    }
    
    func testURLPopultedCorrectly(){
        feed.URL = testData["url"] as? String
        XCTAssertEqual(feed.URL!, testData["url"] as! String, "url is not correctly populated")
    }
    
    func testReadPopultedCorrectly(){
        feed.read = testData["read"] as? Bool
        XCTAssertEqual(feed.read!, testData["read"] as! Bool, "read is not correctly populated")
    }
    
    func testBookmarkedPopultedCorrectly(){
        feed.bookmarked = testData["bookmarked"] as? Bool
        XCTAssertEqual(feed.bookmarked!, testData["bookmarked"] as! Bool, "bookmarked is not correctly populated")
    }
}
