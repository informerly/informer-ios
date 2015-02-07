//
//  MenuViewController.swift
//  Informerly
//
//  Created by Apple on 06/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
class MenuViewController:UIViewController {
    
    private var actInd : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyGradient()
        
        actInd = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
        actInd.hidden = true
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onLogoutPressed(sender: AnyObject) {
        actInd.hidden = false
        actInd.startAnimating()
        var parameters = ["auth_token":Utilities.sharedInstance.getStringForKey(AUTH_TOKEN),
                          "client_id":"dev-ios-informer"]
        NetworkManager.sharedNetworkClient().processDeleteRequestWithPath(LOGOUT_URL,
            parameter: parameters,
            success: { (requestStatus : Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                self.actInd.stopAnimating()
                Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                Utilities.sharedInstance.setStringForKey(AUTH_TOKEN, key: "")
                
                var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as LoginViewController
                self.showViewController(loginVC, sender: self)
                
                
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                self.actInd.stopAnimating()
                println(error.localizedDescription)
            }
    }
    
    @IBAction func onFeedbackPressed(sender: AnyObject) {
    }
    
    @IBAction func onHelpPressed(sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}