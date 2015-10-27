//
//  UpdateInterestViewControllerTest.swift
//  Informerly
//
//  Created by Apple on 23/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class UpdateInterestViewControllerTest: XCTestCase {

    var updateInterestVC : UpdateInterestViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        updateInterestVC = storyboard.instantiateViewControllerWithIdentifier("UpdateInterestVC") as! UpdateInterestViewController
        updateInterestVC.loadView()
    }
    
    func testInterestTextViewExists(){
        XCTAssertNotNil(updateInterestVC.interestsTextView, "Interest TextView does not exist.")
    }
    
    func testSendBarBtnExists(){
        updateInterestVC.createNavBarButtons()
        XCTAssertNotNil(updateInterestVC.send_btn, "Send button does not exists")
    }
    
    func testBackBarBtnExists(){
        updateInterestVC.createNavBarButtons()
        XCTAssertNotNil(updateInterestVC.back_btn, "Back button does not exists")
    }
    
    func testSendBtnRespondsToIBAction(){
        updateInterestVC.createNavBarButtons()
        let action = updateInterestVC.send_btn.action
        
        XCTAssertTrue(action == "onSendPress", "Send button does not respond to IBAction.")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
