//
//  SideMenuViewController.swift
//  Informerly
//
//  Created by Apple on 02/04/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import MessageUI

class LeftMenuViewController : UIViewController,MFMailComposeViewControllerDelegate, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var yourFeedView: UIView!
    @IBOutlet weak var bookmarkView: UIView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var menuItems : [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.downloadMenuItems()
        
        self.applyTopBorder(self.helpView)
        self.applyTopBorder(self.logoutView)
        
        var helpTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onHelpTap:"))
        self.helpView.addGestureRecognizer(helpTapGesture)
        
        var logoutTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onLogoutTap:"))
        self.logoutView.addGestureRecognizer(logoutTapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getMenuItemsNotificationSelector:", name:"GetMenuItemsNotification", object: nil)
    }
    
    func downloadMenuItems(){
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            var parameters = ["auth_token":auth_token]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(MENU_FEED_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        MenuItems.sharedInstance.populateItems(processedData["feeds"] as! [AnyObject])
                        self.menuItems = MenuItems.sharedInstance.getItems()
                        self.tableView.reloadData()
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
            }
        } else {
//            self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
        }
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
    
    func onHelpTap(gesture:UIGestureRecognizer){
        self.helpView.backgroundColor = UIColor.lightGrayColor()
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
        self.helpView.backgroundColor = UIColor.clearColor()
    }
    
    func showAlert(title:String, msg:String) {
        var alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // TableView delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count + 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")as! UITableViewCell
        
        var icon_img : UIImageView? = cell.viewWithTag(101) as? UIImageView
        
        if icon_img == nil {
            icon_img = UIImageView()
            icon_img?.tag = 101
            cell.addSubview(icon_img!)
        }
        
        var name = ""
        if indexPath.row == 0 {
            name = "Your Feed"
            icon_img?.frame = CGRectMake(13, 12, 22, 20)
            icon_img!.image = UIImage(named: "icon_home")
        } else if indexPath.row == 1 {
            name = "Bookmarks"
            icon_img?.frame = CGRectMake(15, 12, 14, 18)
            icon_img!.image = UIImage(named: "icon_bookmark")
        } else {
            name = self.menuItems[indexPath.row - 2].name!
            icon_img?.frame = CGRectMake(15, 12, 22, 18)
            icon_img!.image = UIImage(named: "icon_folder")
        }
        
        var menuLabel : UILabel = cell.viewWithTag(102) as! UILabel
        
        menuLabel.font = UIFont(name: "OpenSans-Regular", size: 16.0)
        menuLabel.textColor = UIColor(rgba: "#4A4A4A")
        menuLabel.text = name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.row == 0 {
            self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("YourFeedNotification", object: nil)
        } else if indexPath.row == 1 {
            self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion:nil)
            NSNotificationCenter.defaultCenter().postNotificationName("BookmarkNotification", object: nil)
        } else {
            self.menuContainerViewController.setMenuState(MFSideMenuStateClosed, completion:nil)
            var categoryID : Int? = self.menuItems[indexPath.row - 2].id
            var categoryName : String = self.menuItems[indexPath.row - 2].name!
            var userInfo = ["id" : String(categoryID!),
                            "name" : categoryName]
            NSNotificationCenter.defaultCenter().postNotificationName("CategoryNotification", object: nil, userInfo: userInfo)
        }
    }
    
    // Notication selectors
    @objc func getMenuItemsNotificationSelector(notification: NSNotification) {
        self.downloadMenuItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}