//
//  MenuItemsTests.swift
//  Informerly
//
//  Created by Apple on 14/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class MenuItemsTests: XCTestCase {

    var items : [AnyObject]!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        items = []
        items.append(createTestData())
        items.append(createTestData())
        items.append(createTestData())
        items.append(createTestData())
        items.append(createTestData())
    }
    
    // Helper methods
    func createTestData()->[String:AnyObject]{
        
        var testData : [String:AnyObject] = [:]
        testData["id"] = 79
        testData["magic"] = "media news cms"
        testData["name"] = "Media"
        testData["primary"] = false
        testData["user_id"] = 202
        
        return testData
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Test cases
    func testItemsSharedInstanceNotNil() {
        XCTAssertNotNil(MenuItems.sharedInstance, "Shared Instance is not available.")
    }
    
    func testGetMenuItemsIsNotNil(){
        MenuItems.sharedInstance.populateItems(items)
        XCTAssertNotNil(MenuItems.sharedInstance.getItems(), "getItems return nil.")
    }
    
    func testGetItemsReturnsSameCount(){
        MenuItems.sharedInstance.populateItems(items)
        XCTAssertEqual(MenuItems.sharedInstance.getItems().count, 5, "Items returns the wrong count.")
    }

    func testGetItemsHasCorrectData(){
        MenuItems.sharedInstance.populateItems(items)
        var id = MenuItems.sharedInstance.getItems().first?.id!
        XCTAssertEqual(id!, 79, "Items does not have the same data")
    }
}
