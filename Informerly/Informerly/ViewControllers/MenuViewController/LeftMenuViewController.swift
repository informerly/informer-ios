//
//  SideMenuViewController.swift
//  Informerly
//
//  Created by Apple on 02/04/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class LeftMenuViewController : UIViewController {
    
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.applyBottonBorder(self.helpView)
        self.applyBottonBorder(self.feedbackView)
        self.applyBottonBorder(self.logoutView)
        
        var helpTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onHelpTap:"))
        self.helpView.addGestureRecognizer(helpTapGesture)
        
        var feedbackTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onFeedbackTap:"))
        self.feedbackView.addGestureRecognizer(feedbackTapGesture)
        
        var logoutTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onLogoutTap:"))
        self.logoutView.addGestureRecognizer(logoutTapGesture)
    }
    
    func applyBottonBorder(view:UIView) {
        var bottomBorder : CALayer = CALayer()
        bottomBorder.borderWidth = 0.5
        bottomBorder.borderColor = UIColor(rgba: "#E6E7E8").CGColor
        bottomBorder.frame = CGRectMake(0, view.frame.size.height - 1, view.frame.size.width, 1)
        view.layer.addSublayer(bottomBorder)
    }
    
    func onHelpTap(gesture:UIGestureRecognizer){
        self.menuContainerViewController.menuState = MFSideMenuStateClosed
        var helpVC = self.storyboard?.instantiateViewControllerWithIdentifier("HelpVC") as! HelpViewController
        self.showViewController(helpVC, sender: self)
    }
    
    func onFeedbackTap(gesture:UIGestureRecognizer){
        self.menuContainerViewController.menuState = MFSideMenuStateClosed
        var feedbackVC = self.storyboard?.instantiateViewControllerWithIdentifier("FeedbackVC") as! FeedbackViewContoller
        self.showViewController(feedbackVC, sender: self)
    }
    
    func onLogoutTap(gesture:UIGestureRecognizer){
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var parameters = ["auth_token":Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
                "client_id":"dev-ios-informer"]
            NetworkManager.sharedNetworkClient().processDeleteRequestWithPath(LOGOUT_URL,
                parameter: parameters,
                success: { (requestStatus : Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                    Utilities.sharedInstance.setAuthToken("", key: AUTH_TOKEN)
                    Utilities.sharedInstance.setBoolForKey(false, key: FROM_MENU_VC)
                    
                    NSUserDefaults.standardUserDefaults().setObject([], forKey: READ_ARTICLES)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                    self.showViewController(loginVC, sender: self)
                    
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    println(error.localizedDescription)
            }
        } else {
            self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
        }
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