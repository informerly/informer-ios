//
//  CategoryFeedsTests.swift
//  Informerly
//
//  Created by Apple on 14/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class CategoryFeedsTests: XCTestCase {
    
    var categoryFeeds:[AnyObject]!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        categoryFeeds = []
        categoryFeeds.append(createTestData())
        categoryFeeds.append(createTestData())
        categoryFeeds.append(createTestData())
        categoryFeeds.append(createTestData())
        categoryFeeds.append(createTestData())
    }
    
    // Helper methods
    func createTestData()->[String:AnyObject] {
        
        var testData:[String:AnyObject] = [:]
        
        testData["id"] = 38192
        testData["title"] = "News Sites Are Fatter And Slower Than Ever"
        testData["description"] = "An analysis of download times highlights how poorly designed news sites are. That’s more evidence of poor implementation of ads… and a strong case for ad blockers."
        testData["reading_time"] = 6
        testData["source"] =  "Monday Note"
        testData["published_at"] = "2015-07-13T22:25:51.391-04:00"
        testData["original_date"] = "2015-07-13T22:25:51.391-04:00"
        testData["slug"] = "news-sites-are-fatter-and-slower-than-ever"
        testData["url"] = "http://www.mondaynote.com/2015/07/13/news-sites-are-fatter-and-slower-than-ever/?curator=Informerly"
        testData["read"] = true
        testData["bookmarked"] = false
        testData["source_color"] = "#ae1414"
        
        return testData
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Test cases
    func testCategoryFeedsSharedInstanceNotNil() {
        XCTAssertNotNil(CategoryFeeds.sharedInstance, "Shared Instance is not available.")
    }
    
    func testGetMenuItemsIsNotNil(){
        CategoryFeeds.sharedInstance.populateFeeds(categoryFeeds, categoryID: 79)
        XCTAssertNotNil(CategoryFeeds.sharedInstance.getCategoryFeeds(79), "getFeeds return nil.")
    }
    
    func testGetItemsReturnsSameCount(){
        CategoryFeeds.sharedInstance.populateFeeds(categoryFeeds, categoryID: 79)
        XCTAssertEqual(CategoryFeeds.sharedInstance.getCategoryFeeds(79)!.count, 5, "Feeds returns the wrong count.")
    }
    
    func testGetItemsHasCorrectData(){
        CategoryFeeds.sharedInstance.populateFeeds(categoryFeeds, categoryID: 79)
        let id = CategoryFeeds.sharedInstance.getCategoryFeeds(79)!.first?.id!
        XCTAssertEqual(id!, 38192, "Feeds does not have the same data")
    }

}
