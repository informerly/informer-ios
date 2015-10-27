//
//  ItemTests.swift
//  Informerly
//
//  Created by Apple on 14/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class ItemTests: XCTestCase {

    var item : Item!
    var testData : [String:AnyObject]!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        item = Item()
        createTestData()
    }
    
    // Helper method 
    func createTestData(){
        testData = [:]
        testData["id"] = 79
        testData["magic"] = "media news cms"
        testData["name"] = "Media"
        testData["primary"] = false
        testData["user_id"] = 202
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // Test cases
    func testItemObjectIsNotNil(){
        XCTAssertNotNil(item, "item object is nil")
    }
    
    func testIDIsPopulatedCorrectly(){
        item.id = testData["id"] as? Int
        XCTAssertEqual(item.id!, testData["id"] as? Int, "Id is not assigned correctly")
    }
    
    func testMagicPopulatedCorrectly(){
        item.magic = testData["magic"] as? String
        XCTAssertEqual(item.magic!, testData["magic"] as? String, "Magic is not assigned correctly")
    }
    
    func testNamePopulatedCorrectly(){
        item.name = testData["name"] as? String
        XCTAssertEqual(item.name!, testData["name"] as? String, "Name is not populated correctly")
    }
    
    func testPrimaryPopulatedCorrectly(){
        item.primary = testData["primary"] as? Int
        XCTAssertEqual(item.primary!, testData["primary"] as? Int, "Primary is not assigned correctly")
    }
    
    func testUserIDPopulatedCorrectly(){
        item.user_id = testData["user_id"] as? Int
        XCTAssertEqual(item.user_id!, testData["user_id"] as? Int, "User id is not assigned correctly")
    }
    

}
