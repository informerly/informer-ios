//
//  SettingViewControllerTest.swift
//  Informerly
//
//  Created by Apple on 22/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class SettingViewControllerTest: XCTestCase {

    var settingVC : SettingsViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        settingVC = storyboard.instantiateViewControllerWithIdentifier("SettingsVC") as! SettingsViewController
        settingVC.loadView()
    }
    
    func testArticleViewSwitchExists(){
        XCTAssertNotNil(settingVC.articleViewSwitch, "Article switch should exist")
    }
    
    func testDefaultViewSwitchExists(){
        XCTAssertNotNil(settingVC.defaultListSwitch, "DefaultList switch should exist")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
