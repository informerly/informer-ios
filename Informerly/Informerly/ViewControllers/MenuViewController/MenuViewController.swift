//
//  MenuViewController.swift
//  Informerly
//
//  Created by Apple on 06/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
class MenuViewController:UIViewController {
    
    private var indicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyGradient()
        
        indicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2 - 25,self.view.frame.height/2 - 25, 50, 50)) as UIActivityIndicatorView
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        view.addSubview(indicator)
        indicator.hidden = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
        self.navigationController?.navigationBar.hidden = true
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
    
    @IBAction func onCrossPressed(sender: AnyObject) {
        Utilities.sharedInstance.setBoolForKey(true, key: FROM_MENU_VC)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onLogoutPressed(sender: AnyObject) {
        indicator.hidden = false
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            indicator.startAnimating()
            var parameters = ["auth_token":Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
                "client_id":"dev-ios-informer"]
            NetworkManager.sharedNetworkClient().processDeleteRequestWithPath(LOGOUT_URL,
                parameter: parameters,
                success: { (requestStatus : Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    self.indicator.stopAnimating()
                    Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
//                    Utilities.sharedInstance.setStringForKey(AUTH_TOKEN, key: "")
                    Utilities.sharedInstance.setAuthToken(AUTH_TOKEN, key: "")
                    Utilities.sharedInstance.setBoolForKey(false, key: FROM_MENU_VC)
                    
                    var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as LoginViewController
                    self.showViewController(loginVC, sender: self)
                    
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    self.indicator.stopAnimating()
                    println(error.localizedDescription)
            }
        } else {
            self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
        }
    }
    
    @IBAction func onFeedbackPressed(sender: AnyObject) {
    }
    
    @IBAction func onHelpPressed(sender: AnyObject) {
    }
    
    func showAlert(title:String, msg:String) {
        var alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}