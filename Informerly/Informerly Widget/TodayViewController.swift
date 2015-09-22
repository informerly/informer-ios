//
//  TodayViewController.swift
//  Informerly Widget
//
//  Created by Apple on 20/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var feedLabelContainingView: UIView!
    @IBOutlet weak var feedLabel: UILabel!
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prevFeedBtn: UIButton!
    @IBOutlet weak var nextFeedBtn: UIButton!
    @IBOutlet weak var prevStoryBtn: UIButton!
    @IBOutlet weak var nextStoryBtn: UIButton!
    @IBOutlet weak var saveStoryBtn: UIButton!
    @IBOutlet weak var readStoryBtn: UIButton!
    var feeds : [AnyObject]!
    var informerlyfeeds : [InformerlyFeed]!
    var menuItems : [Item] = []
    var index : Int!
    var feedIndex : Int!
    var categoryFeeds : [InformerlyFeed]? = []
    var isCategoryFeeds : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        index = 0
        feedIndex = -1
        self.feeds = []
        self.informerlyfeeds = []
        
        containingView.layer.borderColor = UIColor(rgba: BORDER_COLOR).CGColor
        containingView.layer.borderWidth = 1.0
        
        feedLabel.layer.borderColor = UIColor(rgba: BORDER_COLOR).CGColor
        feedLabel.layer.borderWidth = 1.0
        
        // Apply border
        applyBorder(self.prevStoryBtn)
        applyBorder(self.nextStoryBtn)
        applyBorder(self.saveStoryBtn)
        applyBorder(self.readStoryBtn)
        
        // Gesture
        let tap = UITapGestureRecognizer(target: self, action: "onTitleTap")
        self.titleLabel.addGestureRecognizer(tap)
        titleLabel.userInteractionEnabled = true
        
        self.activityIndicator.stopAnimating()
        self.downloadMenuItems()
        
        let token : String! = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
        
        if token != nil && token != "" {
            let parameters = ["auth_token":token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath("feeds",
                parameter: parameters,
                success: { (requestStatus : Int32, processedData : AnyObject!, extraInfo : AnyObject!) -> Void in
                    if requestStatus == 200 {
                        let data : [AnyObject] = processedData["links"] as! Array
                        
//                        var feed : [String:AnyObject]!
                        for feed in data {
                            if feed["read"] as! Bool == false {
                                self.feeds.append(feed)
                            }
                        }
                        Feeds.sharedInstance.populateFeeds(self.feeds)
                        self.informerlyfeeds = Feeds.sharedInstance.getFeeds()
                        
                        self.feedLabelContainingView.hidden = false
                        self.prevFeedBtn.enabled = false
                        self.titleLabel.text = self.informerlyfeeds[self.index].title!
                        if self.informerlyfeeds[self.index].bookmarked! == true {
                            self.saveStoryBtn.backgroundColor = UIColor(rgba: BORDER_COLOR)
                            self.saveStoryBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                        }
                        self.prevStoryBtn.hidden = false
                        self.prevStoryBtn.enabled = false
                        self.prevStoryBtn.alpha = 0.3
                        self.nextStoryBtn.hidden = false
                        self.saveStoryBtn.hidden = false
                        self.readStoryBtn.hidden = false
                    }
                }) { (status : Int32, error : NSError!, extraInfo:AnyObject!) -> Void in
                    print("error")
            }
        } else {
            self.titleLabel.text = "Unable to load title."
            self.nextStoryBtn.hidden = true
        }
    }
    
    
    func downloadMenuItems(){
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let parameters = ["auth_token":auth_token]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(MENU_FEED_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        MenuItems.sharedInstance.populateItems(processedData["feeds"] as! [AnyObject])
                        self.menuItems = MenuItems.sharedInstance.getItems()
                        self.feedLabel.text = "Your Feed"
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
            }
        } else {
        }
    }
    
    func applyBorder(button:UIButton) {
        button.layer.borderColor = UIColor(rgba: BORDER_COLOR).CGColor
        button.layer.borderWidth = 1.0
    }
    
    func onTitleTap() {
        
        let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
        
        var feeds : [InformerlyFeed] = []
        if (isCategoryFeeds == true) {
            feeds = self.categoryFeeds!
            userDefaults.setBool(true, forKey: IS_CATEGORY_FEED)
            userDefaults.setInteger(self.menuItems[self.feedIndex].id!, forKey: CATEGORY_FEED_ID)
            userDefaults.setObject(self.menuItems[self.feedIndex].name!, forKey: CATEGORY_FEED_NAME)
            userDefaults.setInteger(feeds[self.index].id!, forKey: CATEGORY_FEED_ARTICLE_ID)
        } else {
            userDefaults.setBool(false, forKey: IS_CATEGORY_FEED)
            feeds = self.informerlyfeeds
        }
        
//        if feeds != nil {
        
            userDefaults.setObject("\(feeds[self.index].id!)", forKey: "id")
            userDefaults.synchronize()
            
            let url =  NSURL(string:"TodayExtension://home")
            self.extensionContext?.openURL(url!, completionHandler:{(success: Bool) -> Void in
                print("task done!")
            })
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        let newMargins : UIEdgeInsets = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left, bottom: 10.0, right: 15.0)
        return newMargins
    }
    
    
    @IBAction func onPrevBtnPressed(sender: AnyObject) {
        var feeds : [InformerlyFeed] = []
        if (self.isCategoryFeeds == true) {
            feeds = self.categoryFeeds!
        } else {
            feeds = self.informerlyfeeds
        }
        
        self.index = self.index - 1
        if self.index == 0 {
            self.prevStoryBtn.enabled = false
            self.prevStoryBtn.alpha = 0.3
        } else {
            self.prevStoryBtn.enabled = true
            self.prevStoryBtn.alpha = 1
            self.nextStoryBtn.enabled = true
            self.nextStoryBtn.alpha = 1
        }
        
        self.titleLabel.text = feeds[self.index].title!
        
        if feeds[self.index].bookmarked! == true {
            self.saveStoryBtn.backgroundColor = UIColor(rgba: BORDER_COLOR)
            self.saveStoryBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        } else {
            self.saveStoryBtn.backgroundColor = UIColor.clearColor()
            self.saveStoryBtn.setTitleColor(UIColor(rgba: BORDER_COLOR), forState: UIControlState.Normal)
        }
        
    }
    
    @IBAction func onNextBtnPressed(sender: AnyObject) {
        var feeds : [InformerlyFeed] = []
        if (self.isCategoryFeeds == true) {
            feeds = self.categoryFeeds!
        } else {
            feeds = self.informerlyfeeds
        }
        
        self.index = self.index + 1
        if self.index == feeds.count {
            self.nextStoryBtn.enabled = false
            self.nextStoryBtn.alpha = 0.3
            self.index = self.index - 1
        } else {
            self.nextStoryBtn.enabled = true
            self.nextStoryBtn.alpha = 1
            self.prevStoryBtn.enabled = true
            self.prevStoryBtn.alpha = 1
            
            self.titleLabel.text = feeds[self.index].title!
            
            if feeds[self.index].bookmarked! == true {
                self.saveStoryBtn.backgroundColor = UIColor(rgba: BORDER_COLOR)
                self.saveStoryBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            } else {
                self.saveStoryBtn.backgroundColor = UIColor.clearColor()
                self.saveStoryBtn.setTitleColor(UIColor(rgba: BORDER_COLOR), forState: UIControlState.Normal)
            }
        }
    }
    
//    @IBAction func onOpenBtnPressed(sender: AnyObject) {
//        if self.feeds != nil {
//            var feed : [String:AnyObject] = self.feeds[self.index] as! Dictionary
//            var id : Int = self.feeds[self.index]["id"] as! Int
//            
//            var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
//            userDefaults.setObject("\(id)", forKey: "id")
//            userDefaults.setBool(true, forKey: FROM_TODAY_WIDGET)
//            userDefaults.synchronize()
//            
//            var url =  NSURL(string:"TodayExtension://home")
//            self.extensionContext?.openURL(url!, completionHandler:{(success: Bool) -> Void in
//                println("task done!")
//            })
//        }
//    }
    
    @IBAction func onReadBtnPressed(sender: AnyObject) {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            
            self.activityIndicator.startAnimating()
            
            var articleID = -1
            var feeds : [InformerlyFeed] = []
            if (self.isCategoryFeeds == true) {
                feeds = self.categoryFeeds!
                articleID = feeds[self.index].id!
            } else {
                feeds = self.informerlyfeeds
                articleID = feeds[self.index].id!
            }
            
            let parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
                "client_id":"",
                "link_id": articleID]
            
            let path = "links/\(articleID)/read"
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    print("Successfully marked as read.")
                    self.activityIndicator.stopAnimating()
                    feeds.removeAtIndex(self.index)
                    self.index = self.index - 1
                    if self.index <= 0 {
                        self.index = 0
                        self.prevStoryBtn.enabled = false
                        self.prevStoryBtn.alpha = 0.3
                    }
                    
                    self.titleLabel.text = feeds[self.index].title!
                    
                    if feeds[self.index].bookmarked! == true {
                        self.saveStoryBtn.backgroundColor = UIColor(rgba: BORDER_COLOR)
                        self.saveStoryBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    } else {
                        self.saveStoryBtn.backgroundColor = UIColor.clearColor()
                        self.saveStoryBtn.setTitleColor(UIColor(rgba: BORDER_COLOR), forState: UIControlState.Normal)
                    }

                    
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    print("Failure marking article as read")
            }
        }
        
    }
    
    @IBAction func onSaveBtnPressed(sender: AnyObject) {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            self.activityIndicator.startAnimating()
            var feeds : [InformerlyFeed] = []
            if (self.isCategoryFeeds == true) {
                feeds = self.categoryFeeds!
            } else {
                feeds = self.informerlyfeeds
            }
            
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let link_id = feeds[self.index].id!
            let parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "link_id":"\(link_id)"]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        print("saved")
                        self.activityIndicator.stopAnimating()
                        if (feeds[self.index].bookmarked! == false) {
                            feeds[self.index].bookmarked! = true
                            self.saveStoryBtn.backgroundColor = UIColor(rgba: BORDER_COLOR)
                            self.saveStoryBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                        } else {
                            self.saveStoryBtn.backgroundColor = UIColor.clearColor()
                            self.saveStoryBtn.setTitleColor(UIColor(rgba: BORDER_COLOR), forState: UIControlState.Normal)
                        }
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    
                    if extraInfo != nil {
//                        var error : [String:AnyObject] = extraInfo as! Dictionary
//                        var message : String = error["error"] as! String
                    }
            }
        }
    }
    
    @IBAction func onNextFeedPressed(sender: AnyObject) {
        self.index = 0
        self.feedIndex = self.feedIndex + 1
        
        if self.feedIndex + 1 == self.menuItems.count {
            self.nextFeedBtn.enabled = false
            self.feedLabel.text = self.menuItems[self.feedIndex].name!
        } else {
            self.feedLabel.text = self.menuItems[self.feedIndex].name!
        }
        
        self.prevFeedBtn.enabled = true
        self.isCategoryFeeds = true
        self.downloadCategory(self.menuItems[self.feedIndex].id!)
    }
    
    @IBAction func onPrevFeedPressed(sender: AnyObject) {
        self.index = 0
        self.feedIndex = self.feedIndex - 1
        
        if (self.feedIndex == -1) {
            self.feedLabel.text = "Your Feed"
            self.prevFeedBtn.enabled = false
            self.isCategoryFeeds = false
            self.titleLabel.text = self.informerlyfeeds[self.index].title!
        } else if (self.feedIndex >= 0) {
            self.feedLabel.text = self.menuItems[self.feedIndex].name!
            self.downloadCategory(self.menuItems[self.feedIndex].id!)
        } else {
            self.prevFeedBtn.enabled = false
        }
        
        self.nextFeedBtn.enabled = true
    }
    
    
    func downloadCategory(feedID : Int){
        
        self.categoryFeeds = CategoryFeeds.sharedInstance.getCategoryFeeds(feedID)
        
        if  (self.categoryFeeds == nil || self.categoryFeeds!.isEmpty) {
            if (Utilities.sharedInstance.isConnectedToNetwork() == true) {
                self.activityIndicator.startAnimating()
                self.disableView()
                let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
                let parameters = ["auth_token":auth_token,
                    "content":"true"]
                let URL = "\(FEED_URL)/\(feedID)"
                
                NetworkManager.sharedNetworkClient().processGetRequestWithPath(URL,
                    parameter: parameters,
                    success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                        
                        if requestStatus == 200 {
                            self.activityIndicator.stopAnimating()
                            self.enableView()
                            CategoryFeeds.sharedInstance.populateFeeds(processedData["links"] as! [AnyObject], categoryID: feedID)
                            self.categoryFeeds = CategoryFeeds.sharedInstance.getCategoryFeeds(feedID)
                            
                            if self.categoryFeeds == nil || self.categoryFeeds!.isEmpty {
                                self.titleLabel.text = "Unable to load ... "
                            } else {
                                var tempFeeds : [InformerlyFeed] = []
                                for feed : InformerlyFeed in self.categoryFeeds! {
                                    if feed.read == false {
                                        tempFeeds.append(feed)
                                    }
                                }
                                self.categoryFeeds = tempFeeds
                                self.titleLabel.text = self.categoryFeeds![self.index].title!
                                
                                if self.categoryFeeds![self.index].bookmarked! == true {
                                    self.saveStoryBtn.backgroundColor = UIColor(rgba: BORDER_COLOR)
                                    self.saveStoryBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                                } else {
                                    self.saveStoryBtn.backgroundColor = UIColor.clearColor()
                                    self.saveStoryBtn.setTitleColor(UIColor(rgba: BORDER_COLOR), forState: UIControlState.Normal)
                                }
                            }
                        }
                    }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                        self.activityIndicator.stopAnimating()
                        if extraInfo != nil {
//                            var error : [String:AnyObject] = extraInfo as! Dictionary
//                            var message : String = error["error"] as! String
                        }
                }
            }
        } else {
            self.titleLabel.text = self.categoryFeeds![self.index].title!
        }
    }
    
    func disableView() {
        self.nextFeedBtn.enabled = false
        self.prevFeedBtn.enabled = false
        self.nextStoryBtn.enabled = false
        self.prevStoryBtn.enabled = false
        self.readStoryBtn.enabled = false
        self.saveStoryBtn.enabled = false
        self.titleLabel.userInteractionEnabled = false
        
        self.nextStoryBtn.alpha = 0.3
        self.prevStoryBtn.alpha = 0.3
        self.readStoryBtn.alpha = 0.3
        self.saveStoryBtn.alpha = 0.3
        self.nextFeedBtn.alpha = 0.3
        self.prevFeedBtn.alpha = 0.3
    }
    
    func enableView() {
        self.nextFeedBtn.enabled = true
        self.prevFeedBtn.enabled = true
        self.nextStoryBtn.enabled = true
        self.prevStoryBtn.enabled = false
        self.readStoryBtn.enabled = true
        self.saveStoryBtn.enabled = true
        self.titleLabel.userInteractionEnabled = true
        
        self.nextStoryBtn.alpha = 1
        self.readStoryBtn.alpha = 1
        self.saveStoryBtn.alpha = 1
        self.nextFeedBtn.alpha = 1
        self.prevFeedBtn.alpha = 1
    }
    
}
