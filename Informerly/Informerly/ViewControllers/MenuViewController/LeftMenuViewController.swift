//
//  SideMenuViewController.swift
//  Informerly
//
//  Created by Apple on 02/04/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import MessageUI

class LeftMenuViewController : UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var yourFeedView: UIView!
    @IBOutlet weak var bookmarkView: UIView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.applyBottomBorder(self.yourFeedView)
        self.applyBottomBorder(self.bookmarkView)
        self.applyTopBorder(self.helpView)
        self.applyTopBorder(self.logoutView)
        
        var yourFeedTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onYourFeedTap:"))
        self.yourFeedView.addGestureRecognizer(yourFeedTapGesture)
        
        var bookmarkTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onBookmarkTap:"))
        self.bookmarkView.addGestureRecognizer(bookmarkTapGesture)
        
        var helpTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onHelpTap:"))
        self.helpView.addGestureRecognizer(helpTapGesture)
        
        var logoutTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onLogoutTap:"))
        self.logoutView.addGestureRecognizer(logoutTapGesture)
    }
    
    func applyTopBorder(view:UIView) {
        var topBorder : CALayer = CALayer()
        topBorder.borderWidth = 0.5
        topBorder.borderColor = UIColor(rgba: "#E6E7E8").CGColor
        topBorder.frame = CGRectMake(0, 0, view.frame.size.width, 1)
        view.layer.addSublayer(topBorder)
    }
    
    func applyBottomBorder(view:UIView) {
        var bottomBorder : CALayer = CALayer()
        bottomBorder.borderWidth = 0.5
        bottomBorder.borderColor = UIColor(rgba: "#E6E7E8").CGColor
        bottomBorder.frame = CGRectMake(0, view.frame.size.height - 1, view.frame.size.width, 1)
        view.layer.addSublayer(bottomBorder)
    }
    
    func onYourFeedTap(gesture:UIGestureRecognizer){
        self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("YourFeedNotification", object: nil)
    }
    
    func onBookmarkTap(gesture:UIGestureRecognizer){
        self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("BookmarkNotification", object: nil)
    }
    
    func onHelpTap(gesture:UIGestureRecognizer){
        self.openMailComposer()
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
    
    func openMailComposer(){
        var emailTitle = "Help / Feedback"
        var messageBody = "Enter your questions, problems, or comments here. We’ll respond as soon as we can:"
        var toRecipents = ["support@informerly.com"]
        
        var mailComposer: MFMailComposeViewController = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject(emailTitle)
        mailComposer.setToRecipients(toRecipents)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
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