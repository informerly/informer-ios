//
//  LoginViewControllerTests.swift
//  Informerly
//
//  Created by Apple on 22/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import XCTest

class LoginViewControllerTests: XCTestCase {
    
    var loginVC : LoginViewController!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        loginVC.loadView()
    }
    
    func testEmailViewExists(){
        XCTAssertNotNil(loginVC.emailView, "Email View should exist")
    }
    
    func testPasswordViewExists(){
        XCTAssertNotNil(loginVC.passwordView, "Password View should exist")
    }
    
    func testEmailTextFieldExists(){
        XCTAssertNotNil(loginVC.emailTextField, "Email field should exist")
    }
    
    func testPasswordTextFieldExists(){
        XCTAssertNotNil(loginVC.signInBtn, "Password field should exist")
    }
    
    func testSignInButtonExists(){
        XCTAssertNotNil(loginVC.signInBtn, "SignIn button should exist")
    }
    
    func testSignInButtonConnected(){
        var actions : [String] = loginVC.signInBtn.actionsForTarget(loginVC, forControlEvent: UIControlEvents.TouchUpInside) as! [String]
        XCTAssertTrue(contains(actions, "onSignInBtnPress:"), "SignIn IBAction not connected")
    }
    
    func testForgotPasswordBtnExits(){
        XCTAssertNotNil(loginVC.forgotPasswordBtn, "ForgotPassword Button should exist")
    }
    
    func testForgotPasswordButtonConnected(){
        var actions : [String] = loginVC.forgotPasswordBtn.actionsForTarget(loginVC, forControlEvent: UIControlEvents.TouchUpInside) as! [String]
        XCTAssertTrue(contains(actions, "onForgotPasswordPressed:"), "ForgotPassword IBAction not connected")
    }
    
    func testEmailPlaceholderSetsProperly(){
        loginVC.setTextFieldPlaceholder()
        XCTAssertNotEqual(loginVC.emailTextField.text, "name@email.com", "Email placeholder is not set properly.")
    }
    
    func testPasswordPlaceholderSetsProperly(){
        loginVC.setTextFieldPlaceholder()
        XCTAssertNotEqual(loginVC.passwordTextField.text, "****", "Password placeholder is not set properly.")
    }
    
    func testResetFieldsResetsTheFields(){
        loginVC.resetFields()
        XCTAssertEqual(loginVC.emailTextField.text, "", "Email text field should be empty.")
        XCTAssertEqual(loginVC.passwordTextField.text, "", "Password text field should be empty.")
    }
    
    func testGradientAppliedProperly(){
        loginVC.applyGradient()
        var gradient : CAGradientLayer? = loginVC.view.layer.sublayers[0] as? CAGradientLayer
        XCTAssertNotNil(gradient, "Gradient is nil")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
