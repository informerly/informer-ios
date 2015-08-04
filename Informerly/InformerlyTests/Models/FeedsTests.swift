//
//  FeedsTests.swift
//  Informerly
//
//  Created by Apple on 14/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class FeedsTests: XCTestCase {

//    var testData:[String:AnyObject]!
    var feeds:[AnyObject]!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        feeds = []
        feeds.append(self.createTestData())
        feeds.append(self.createTestData())
        feeds.append(self.createTestData())
        feeds.append(self.createTestData())
        feeds.append(self.createTestData())
    }
    
    // Helper methods
    func createTestData()->[String:AnyObject] {
        
        var testData:[String:AnyObject] = [:]
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
        
        return testData
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test cases
    func testFeedsSharedInstanceNotNil() {
        XCTAssertNotNil(Feeds.sharedInstance, "Shared Instance is not available.")
    }
    
    func testGetFeedsIsNotNil(){
        Feeds.sharedInstance.populateFeeds(feeds)
        XCTAssertNotNil(Feeds.sharedInstance.getFeeds(), "getFeeds return nil.")
    }
    
    func testGetFeedsReturnsSameCount(){
        Feeds.sharedInstance.populateFeeds(feeds)
        XCTAssertEqual(Feeds.sharedInstance.getFeeds().count, 5, "Feeds returns the wrong count.")
    }
    
    func testGetFeedsHasCorrectData(){
        Feeds.sharedInstance.populateFeeds(feeds)
        var id = Feeds.sharedInstance.getFeeds().first?.id!
        XCTAssertEqual(id!, 38150, "Feeds does not have the same data")
    }

}
