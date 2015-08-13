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
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    private var indicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Nav bar
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.navigationBar.hidden = true
        
        self.applyGradient()
        self.setCornerRadius()
        self.setTextFieldPlaceholder()
        
        self.signInBtn.enabled = false
        self.emailTextField.delegate = self
        self.emailTextField.keyboardType = UIKeyboardType.EmailAddress
        self.passwordTextField.delegate = self
        
        // Keyboard notifications
        if self.view.frame.height == 480 {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name: UIKeyboardDidShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardDidHideNotification, object: nil)
        }
        
        // Activity indicator
        indicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2 - 25, 0, 0)) as UIActivityIndicatorView
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        view.addSubview(indicator)
    }
    
    func applyGradient() {
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        
        let lightBlueColor = UIColor(rgba : LIGHT_BLUE_COLOR).CGColor
        let darkBlueColor = UIColor(rgba : DARK_BLUE_COLOR).CGColor
        let arrayColors = [lightBlueColor, darkBlueColor]
        
        gradient.colors = arrayColors
        view.layer.insertSublayer(gradient, atIndex: 0)

    }
    
    func setCornerRadius() {
        self.emailView.layer.cornerRadius = 8.0
        self.emailView.layer.borderWidth = 1.0
        self.emailView.layer.borderColor = UIColor(rgba: BORDER_COLOR).CGColor
        
        self.passwordView.layer.cornerRadius = 8.0
        self.passwordView.layer.borderWidth = 1.0
        self.passwordView.layer.borderColor = UIColor(rgba: BORDER_COLOR).CGColor
        
        self.signInBtn.layer.cornerRadius = 8.0
    }
    
    func setTextFieldPlaceholder() {
        self.emailTextField.attributedPlaceholder = NSAttributedString(string:"name@email.com",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string:"****",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        self.emailTextField.tintColor = UIColor.whiteColor()
        self.passwordTextField.tintColor = UIColor.whiteColor()
    }
    
    // TextField delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === emailTextField {
            return passwordTextField.becomeFirstResponder()
        } else if textField === passwordTextField {
            return textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = count(textField.text!) + count(string) - range.length
        
        if newLength == 0 {
            textField.alpha = 0.3
        } else {
            textField.alpha = 1.0
        }
        
        if textField === passwordTextField && count(emailTextField.text) > 0 {
            
            if newLength >= 1 {
                signInBtn.enabled = true
                signInBtn.alpha = 1.0
            } else if newLength == 0 {
                signInBtn.enabled = false
                signInBtn.alpha = 0.3
            }
            
        }
        
        if textField === emailTextField && count(passwordTextField.text) > 0 {
            
            if newLength >= 1 {
                signInBtn.enabled = true
                signInBtn.alpha = 1.0
            } else if newLength == 0 {
                signInBtn.enabled = false
                signInBtn.alpha = 0.3
            }
        }
        
        if textField.text == "" && string == "" {
            signInBtn.enabled = false
            signInBtn.alpha = 0.3
            return true
        }
        
        return true
    }
    
    // Keyboard notifications
    func keyboardWillShow() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = CGRectMake(0, -80, self.view.frame.size.width, self.view.frame.size.height)
        })
    }
    
    func keyboardWillHide() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        })
    }
    
    @IBAction func onSignInBtnPress(sender: UIButton) {
        
        self.view.endEditing(true)
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            self.indicator.startAnimating()
            var parameters = ["login":emailTextField.text,
                "password":passwordTextField.text,
                "device_token":""/*Utilities.sharedInstance.getStringForKey(DEVICE_TOKEN)*/]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(LOGIN_URL,
                parameter: parameters,
                success: { (requestStatus: Int32, processedData: AnyObject!, extraInfo:AnyObject!) -> Void in
                    self.indicator.stopAnimating()
                    var data : [String:AnyObject] = processedData as! Dictionary
                    if (data["success"] as! Bool == true) {
                        
                        var user :[String:AnyObject] = data["user"] as! Dictionary
                        if (user["subscribed"] as! Bool == false) {
                            self.resetFields()
                            var unsubscribedVC = self.storyboard?.instantiateViewControllerWithIdentifier("UnsubscribedVC") as! UnsubscribedViewController
                            self.showViewController(unsubscribedVC, sender: self)
                        } else {
                            
                            User.sharedInstance.populateUser(processedData as! Dictionary)
                            Utilities.sharedInstance.setBoolForKey(true, key: IS_USER_LOGGED_IN)
                            Utilities.sharedInstance.setAuthToken(User.sharedInstance.auth_token, key: AUTH_TOKEN)
                            Utilities.sharedInstance.setStringForKey(String(User.sharedInstance.id), key: USER_ID)
                            Utilities.sharedInstance.setStringForKey(self.emailTextField.text.lowercaseString, key: EMAIL)
                            
                            var parseInstallation : PFInstallation = PFInstallation.currentInstallation()
                            parseInstallation["username"] = self.emailTextField.text.lowercaseString
                            parseInstallation["id"] = User.sharedInstance.id
                            parseInstallation.saveInBackgroundWithBlock(nil)
                            
                            var appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.loadFeedVC()
                        }
                    }
                    
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    
                    self.indicator.stopAnimating()
                    
                    self.passwordTextField.text = ""
                    self.passwordTextField.alpha = 0.3
                    self.signInBtn.enabled = false
                    self.signInBtn.alpha = 0.3
                    
                    var error : [String:AnyObject] = extraInfo as! Dictionary
                    var message : String = error["message"] as! String
                    self.showAlert("Error !", msg: message)
            }
        } else {
            self.showAlert("No Signal?  Don't worry!", msg: "You can still read your Saved Articles from the side menu.")
        }
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    @IBAction func onForgotPasswordPressed(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://informerly.com/users/password/new")!)
    }
    
    func resetFields(){
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.emailTextField.alpha = 0.3
        self.passwordTextField.alpha = 0.3
        self.signInBtn.enabled = false
        self.signInBtn.alpha = 0.3
    }
    
    func showAlert(title:String, msg:String) {
        var alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
//    func createCustomPushAlert() {
//        
//        var title = "Please allow us to deliver you targeted, useful alerts."
//        var msg = "We take notifications seriously and guarentee they will be relevant just click 'Yes' and then 'OK'."
//        
//        var alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (sender) -> Void in
//            Utilities.sharedInstance.setBoolForKey(false, key: PUSH_ALLOWED)
//            Utilities.sharedInstance.setIntForKey(0, key: APP_LAUNCH_COUNTER)
//        }))
//        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (sender) -> Void in
//            Utilities.sharedInstance.setBoolForKey(true, key: PUSH_ALLOWED)
//            Utilities.sharedInstance.setIntForKey(0, key: APP_LAUNCH_COUNTER)
//            var appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            appDelegate.configurePushNotification()
//        }))
//        self.presentViewController(alert, animated: true, completion: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}