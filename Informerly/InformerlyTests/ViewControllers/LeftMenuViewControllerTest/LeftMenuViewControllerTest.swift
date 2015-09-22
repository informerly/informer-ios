//
//  LeftMenuViewControllerTest.swift
//  Informerly
//
//  Created by Apple on 23/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class LeftMenuViewControllerTest: XCTestCase {
    
    var leftMenuVC : LeftMenuViewController!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        leftMenuVC = storyboard.instantiateViewControllerWithIdentifier("LeftMenuViewController") as! LeftMenuViewController
        leftMenuVC.loadView()
    }
    
    func testYourFeedViewExists() {
        XCTAssertNotNil(leftMenuVC.yourFeedView, "YourFeedView does not exist.")
    }
    
    func testBookmarkViewExists() {
        XCTAssertNotNil(leftMenuVC.bookmarkView, "BookmarkView does not exist.")
    }
    
    func testSettingViewExists() {
        XCTAssertNotNil(leftMenuVC.settingsView, "SettingView does not exist.")
    }
    
    func testHelpViewExist(){
        XCTAssertNotNil(leftMenuVC.helpView, "HelpView does not exist.")
    }
    
    func testLogoutViewExist(){
        XCTAssertNotNil(leftMenuVC.logoutView, "Logout View does not exist.")
    }
    
    func testTableViewExists() {
        XCTAssertNotNil(leftMenuVC.tableView, "Table View does not exist.")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
