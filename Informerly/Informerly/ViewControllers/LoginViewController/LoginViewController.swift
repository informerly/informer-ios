//
//  LoginViewController.swift
//  Informerly
//
//  Created by Muhammad Junaid Butt on 02/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signInBtn.enabled = false
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === emailTextField {
            return passwordTextField.becomeFirstResponder()
        } else if textField === passwordTextField {
            return textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField === passwordTextField && countElements(emailTextField.text) > 0 {
            let newLength = countElements(textField.text!) + countElements(string) - range.length
            
            if newLength == 1 {
                signInBtn.enabled = true
            } else if newLength == 0 {
                signInBtn.enabled = false
            }
            
        }
        
        if textField === emailTextField && countElements(passwordTextField.text) > 0 {
            let newLength = countElements(textField.text!) + countElements(string) - range.length
            
            if newLength == 1 {
                signInBtn.enabled = true
            } else if newLength == 0 {
                signInBtn.enabled = false
            }
        }
        
        return true
    }
    
    @IBAction func onSignInBtnPress(sender: UIButton) {
        
        var parameters = ["login":emailTextField.text, "password":passwordTextField.text]
        
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(LOGIN_URL,
            parameter: parameters,
            success: { (requestStatus: Int32, processedData: AnyObject!, extraInfo:AnyObject!) -> Void in
                
                var data : [String:AnyObject] = processedData as Dictionary
                if (data["success"] as Bool == true) {
                    User.sharedInstance.populateUser(processedData as Dictionary)
                    Utilities.sharedInstance.setBoolForKey(true, key: IS_USER_LOGGED_IN)
                    Utilities.sharedInstance.setStringForKey(User.sharedInstance.auth_token, key: AUTH_TOKEN)
                    self.performSegueWithIdentifier("FeedVC", sender: self)
                }
                
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                
                var error : [String:AnyObject] = extraInfo as Dictionary
                var message : String = error["message"] as String
                
                var alert = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
    
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}