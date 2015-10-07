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
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var menuItems : [Item] = []
    var refreshCntrl : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Pull to Refresh
        self.refreshCntrl = UIRefreshControl()
        self.refreshCntrl.addTarget(self, action: Selector("onPullToRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshCntrl)
        
        self.downloadMenuItems()
        
        self.applyTopBorder(self.bookmarkView)
        self.applyTopBorder(self.settingsView)
        self.applyTopBorder(self.helpView)
        self.applyTopBorder(self.logoutView)
        
        let bookmarkTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onBookmarkTap:"))
        self.bookmarkView.addGestureRecognizer(bookmarkTapGesture)
        
        let settingTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onSettingTap:"))
        self.settingsView.addGestureRecognizer(settingTapGesture)
        
        let helpTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onHelpTap:"))
        self.helpView.addGestureRecognizer(helpTapGesture)
        
        let logoutTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onLogoutTap:"))
        self.logoutView.addGestureRecognizer(logoutTapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getMenuItemsNotificationSelector:", name:"GetMenuItemsNotification", object: nil)
        
    }
    
    func downloadMenuItems(){
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let parameters = ["auth_token":auth_token]

            NetworkManager.sharedNetworkClient().processGetRequestWithPath(MENU_FEED_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        // Mixpanel track
                        Mixpanel.sharedInstance().track("Menu - Pull to Refresh")
                        
                        self.refreshCntrl.endRefreshing()
                        MenuItems.sharedInstance.populateItems(processedData.objectForKey("feeds") as! [AnyObject])
                        self.menuItems = MenuItems.sharedInstance.getItems()

                        for menuItem : Item in self.menuItems {
                            if (menuItem.id! == Int(Utilities.sharedInstance.getStringForKey(FEED_ID)!)!) {
                                let userInfo = ["id":String(menuItem.id!),"name" : menuItem.name!]
                                NSNotificationCenter.defaultCenter().postNotificationName("CategoryNotification", object: nil, userInfo:userInfo)
                            }
                        }

                        self.tableView.reloadData()
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    self.refreshCntrl.endRefreshing()
            }
        } else {
//            self.showAlert("No Signal?  Don't worry!", msg: "You can still read your Saved Articles from the side menu.")
        }
    }
    
    func applyTopBorder(view:UIView) {
        let topBorder : CALayer = CALayer()
        topBorder.borderWidth = 0.5
        topBorder.borderColor = UIColor(rgba: "#E6E7E8").CGColor
        topBorder.frame = CGRectMake(0, 0, view.frame.size.width, 1)
        view.layer.addSublayer(topBorder)
    }
    
    func applyBottomBorder(view:UIView) {
        let bottomBorder : CALayer = CALayer()
        bottomBorder.borderWidth = 0.5
        bottomBorder.borderColor = UIColor(rgba: "#E6E7E8").CGColor
        bottomBorder.frame = CGRectMake(0, view.frame.size.height - 1, view.frame.size.width, 1)
        view.layer.addSublayer(bottomBorder)
    }
    
    func onSettingTap(gesture:UIGestureRecognizer){
        self.settingsView.backgroundColor = UIColor.lightGrayColor()
        self.mm_drawerController.closeDrawerAnimated(true) { (closed) -> Void in
            self.settingsView.backgroundColor = UIColor.whiteColor()
        }
        NSNotificationCenter.defaultCenter().postNotificationName("SettingsNotification", object: nil)
    }


    func onHelpTap(gesture:UIGestureRecognizer){
        self.helpView.backgroundColor = UIColor.lightGrayColor()
        self.openMailComposer()
    }
    
    func onBookmarkTap(gesture:UIGestureRecognizer){
        self.bookmarkView.backgroundColor = UIColor.lightGrayColor()
        self.mm_drawerController.closeDrawerAnimated(true) { (closed) -> Void in
            self.bookmarkView.backgroundColor = UIColor.whiteColor()
            NSNotificationCenter.defaultCenter().postNotificationName("BookmarkNotification", object: nil)
        }
    }
    
    func onLogoutTap(gesture:UIGestureRecognizer){
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let parameters = ["auth_token":Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
                "client_id":"dev-ios-informer"]
            NetworkManager.sharedNetworkClient().processDeleteRequestWithPath(LOGOUT_URL,
                parameter: parameters,
                success: { (requestStatus : Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    //Mixpanel track
                    Mixpanel.sharedInstance().track("Logout - Informer App")
                    
                    Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                    Utilities.sharedInstance.setAuthToken("", key: AUTH_TOKEN)
                    Utilities.sharedInstance.setBoolForKey(false, key: FROM_MENU_VC)
                    
                    NSUserDefaults.standardUserDefaults().setObject([], forKey: READ_ARTICLES)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                    self.showViewController(loginVC, sender: self)
                    
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    print(error.localizedDescription)
            }
        } else {
            self.showAlert("No Signal?  Don't worry!", msg: "You can still read your Saved Articles from the side menu.")
        }
    }
    
    func openMailComposer(){
        let emailTitle = "Help / Feedback"
        let messageBody = "Enter your questions, problems, or comments here. We’ll respond as soon as we can:"
        let toRecipents = ["support@informerly.com"]
        
        let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject(emailTitle)
        mailComposer.setToRecipients(toRecipents)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.helpView.backgroundColor = UIColor.clearColor()
    }
    
    func showAlert(title:String, msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // TableView delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
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
        } else {
            
            if self.menuItems.count == 0 {
                name = "Bookmarks"
                icon_img?.frame = CGRectMake(15, 12, 14, 18)
                icon_img!.image = UIImage(named: "icon_bookmark")
            } else {
                name = self.menuItems[indexPath.row - 1].name!
                icon_img?.frame = CGRectMake(15, 12, 22, 18)
                icon_img!.image = UIImage(named: "icon_folder")
            }
        }
        
        let menuLabel : UILabel = cell.viewWithTag(102) as! UILabel
        menuLabel.text = name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.row == 0 {
            self.mm_drawerController.closeDrawerAnimated(true, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("YourFeedNotification", object: nil)
        } else {
            self.mm_drawerController.closeDrawerAnimated(true, completion: nil)
            let categoryID : Int? = self.menuItems[indexPath.row - 1].id
            let categoryName : String = self.menuItems[indexPath.row - 1].name!
            let userInfo = ["id" : String(categoryID!),
                            "name" : categoryName]
            NSNotificationCenter.defaultCenter().postNotificationName("CategoryNotification", object: nil, userInfo: userInfo)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    // Notication selectors
    @objc func getMenuItemsNotificationSelector(notification: NSNotification) {
        self.downloadMenuItems()
    }
    
    func onPullToRefresh(sender:AnyObject) {
        self.downloadMenuItems()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}