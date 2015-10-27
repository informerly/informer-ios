//
//  User.swift
//  Informerly
//
//  Created by Apple on 13/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class UserTests: XCTestCase {

    var testData : [String:AnyObject]!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        testData = [:]
        testData["auth_token"] = "adfnasdnfkjasdnf"
        testData["id"] = 23
        testData["username"] = "TestUser"
        testData["full_name"] = "TestFullName"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // Test cases
    func testUserSharedInstanceNotNil() {
        XCTAssertNotNil(User.sharedInstance, "Shared Instance is not available.")
    }
    
    func testAuthTokenPopulatedCorrectly(){
        User.sharedInstance.auth_token = testData["auth_token"] as! String
        XCTAssertEqual(User.sharedInstance.auth_token, testData["auth_token"] as? String, "Auth token is not correctly populated")
    }
    
    func testUserIDPopulatedCorrectly(){
        User.sharedInstance.id = testData["id"] as! Int
        XCTAssertEqual(User.sharedInstance.id, testData["id"] as? Int, "ID is not correctly populated")
    }
    
//    func testUserNamePopulatedCorrectly(){
//        User.sharedInstance.user_name = testData["username"] as! String
//        XCTAssertEqual(User.sharedInstance.user_name, testData["username"] as! String, "User name is not correctly populated")
//    }
//    
//    func testFullNamePopulatedCorrectly(){
//        User.sharedInstance.full_name = testData["full_name"] as! String
//        XCTAssertEqual(User.sharedInstance.full_name, testData["full_name"] as! String, "Full name is not correctly populated")
//    }
    
    func testGetUserNotNil(){
        XCTAssertNotNil(User.sharedInstance.getUser(), "GetUser() returns nil")
    }
    
    func testGetUserHaveCorrectData(){
        
        User.sharedInstance.auth_token = testData["auth_token"] as! String
        User.sharedInstance.id = testData["id"] as! Int
//        User.sharedInstance.user_name = testData["username"] as! String
//        User.sharedInstance.full_name = testData["full_name"] as! String
        
        let user = User.sharedInstance.getUser()
        
        XCTAssertEqual(user.auth_token, testData["auth_token"] as? String, "GetUser does not have correct value to auth_token")
        XCTAssertEqual(user.id, testData["id"] as? Int, "GetUser does not have correct value to id")
//        XCTAssertEqual(user.user_name, testData["username"] as! String, "GetUser does not have correct value to username")
//        XCTAssertEqual(user.full_name, testData["full_name"] as! String, "GetUser does not have correct value to full_name")
    }

}
