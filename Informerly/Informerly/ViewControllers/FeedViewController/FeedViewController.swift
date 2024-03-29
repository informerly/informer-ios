//
//  FeedViewController.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import CoreSpotlight

class FeedViewController : UITableViewController, MGSwipeTableCellDelegate {
    
    private var feeds : [InformerlyFeed] = []
    private var bookmarks : [BookmarkFeed] = []
    private var categoryFeeds : [InformerlyFeed]? = []
    private var unreadFeeds : [InformerlyFeed] = []
    private var unreadBookmarkFeeds : [BookmarkFeed] = []
    private var rowID : Int!
    private var width : CGFloat!
    var refreshCntrl : UIRefreshControl!
    private var isUnreadTab = false
    private var isBookmarked = false
    private var menu:UIBarButtonItem!
    private var navTitle : UILabel!
    private var isPullToRefresh = false
    private var isCategoryFeeds = false
    private var categoryID : Int = -1
    private var categoryName : String = ""
    private var feedData : InformerlyFeed!
    private var bookmarkBtn : MGSwipeButton!
//    private var readBtn : MGSwipeButton!
    private var crossBtn : MGSwipeButton!
    private var customSegmentedControl : UISegmentedControl!
    private var isLinkIDMatched = false
    private var isFromFeeds = true
    private var email:String!
    private var userID:String!
    private var appDelegate : AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"appDidBecomeActiveCalled", name:UIApplicationDidBecomeActiveNotification, object: nil)
        
        email = Utilities.sharedInstance.getStringForKey(EMAIL)!
        userID = Utilities.sharedInstance.getStringForKey(USER_ID)!
        
        // MixPanel tracking
        Mixpanel.sharedInstance().identify(String(userID))
        
        // Intercom Register User
        Intercom.registerUserWithUserId(userID, email: email)
        
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
        if Utilities.sharedInstance.getBoolForKey(PUSH_ALLOWED) == false {
            var appLaunchCounter = Utilities.sharedInstance.getIntForKey(APP_LAUNCH_COUNTER)
            appLaunchCounter++
            Utilities.sharedInstance.setIntForKey(appLaunchCounter, key: APP_LAUNCH_COUNTER)
        }
        
        if Utilities.sharedInstance.getIntForKey(APP_LAUNCH_COUNTER) == 1 || Utilities.sharedInstance.getIntForKey(APP_LAUNCH_COUNTER) == 5 {
            self.createCustomPushAlert()
        }
        
        // Setting Nav bar.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.translucent = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.createNavTitle()
        
        // Adds menu icon on nav bar.
        menu = UIBarButtonItem(image: UIImage(named: ICON_MENU), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onMenuPressed"))
        menu.tintColor = UIColor.grayColor()
        self.navigationItem.leftBarButtonItem = menu
        
        // Adds interest icon on nav bar.
        let interestBtn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: ICON_INTERESTS), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onUpdateYourInterest"))
        interestBtn.tintColor = UIColor.grayColor()
        self.navigationItem.rightBarButtonItem = interestBtn
        
        // Getting screen width.
        width = UIScreen.mainScreen().bounds.width - 40
        
        // TableView separator full width
//        self.tableView.separatorInset = UIEdgeInsetsZero
//        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        //TableView header
        self.createTableViewHeader()
        
        // Pull to Refresh
        self.refreshCntrl = UIRefreshControl()
        self.refreshCntrl.addTarget(self, action: Selector("onPullToRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshCntrl)
        
        self.fetchUserPreferences()
        let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
        if userDefaults.boolForKey(IS_CATEGORY_FEED) == true {
            self.isCategoryFeeds = true
            self.categoryID = userDefaults.integerForKey(CATEGORY_FEED_ID)
            self.categoryName = userDefaults.objectForKey(CATEGORY_FEED_NAME) as! String
            self.downloadCategory(self.categoryID, categoryName: self.categoryName)
            userDefaults.setBool(false, forKey: IS_CATEGORY_FEED)
            userDefaults.setInteger(-1, forKey: CATEGORY_FEED_ID)
            userDefaults.setObject("", forKey: CATEGORY_FEED_NAME)
            userDefaults.synchronize()
        } else if Utilities.sharedInstance.getStringForKey(FEED_ID) == "-1" || Utilities.sharedInstance.getStringForKey(FEED_ID) == nil {
            self.downloadData()
        }
        
        self.downloadBookmark { (result) -> Void in}
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "yourFeedNotificationSelector:", name:"YourFeedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bookmarkNotificationSelector:", name:"BookmarkNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "categoryNotificationSelector:", name:"CategoryNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "settingsNotificationSelector:", name:"SettingsNotification", object: nil)

    }
    
    override func updateUserActivityState(activity: NSUserActivity) {
        print("\(activity.userInfo)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBar.hidden = false
        
        // Side menu set swipe gesture
        self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        self.mm_drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningDrawerView
        
        self.isFromFeeds = true
        
        email = Utilities.sharedInstance.getStringForKey(EMAIL)!
        userID = Utilities.sharedInstance.getStringForKey(USER_ID)!
//        isBookmarked = Utilities.sharedInstance.getBoolForKey(IS_FROM_SPOTLIGHT)
        let isFromSpotlight = Utilities.sharedInstance.getBoolForKey(IS_FROM_SPOTLIGHT)
        Utilities.sharedInstance.setBoolForKey(false, key: IS_FROM_SPOTLIGHT)
        
        if Utilities.sharedInstance.getBoolForKey(FROM_PUSH_AND_FROM_ARTICLE_VIEW) {
            if Utilities.sharedInstance.getStringForKey(FEED_ID) != "-1" {
                loadNewCategory()
            } else {
                downloadData()
            }
            
            Utilities.sharedInstance.setBoolForKey(false, key: FROM_PUSH_AND_FROM_ARTICLE_VIEW)
        } else {
            if isBookmarked == true || isFromSpotlight {
                createNavTitle()
                self.bookmarks = CoreDataManager.getBookmarkFeeds()
                loadArticle()
            } else if isCategoryFeeds == true {
                if self.categoryFeeds == nil {
                    self.categoryFeeds = []
                }
            }
            else {
                createNavTitle()
                self.feeds = Feeds.sharedInstance.getFeeds()
            }
            
            self.tableView.reloadData()
        }
    }
    
    func appDidBecomeActiveCalled(){
        
        if self.mm_drawerController.openSide == MMDrawerSide.Left {
            self.mm_drawerController.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        }
        
        if Utilities.sharedInstance.getBoolForKey(IS_FROM_PUSH) == true {
            
            if (self.navigationController?.topViewController!.isKindOfClass(FeedViewController) == true) {
                if Utilities.sharedInstance.getStringForKey(FEED_ID) == "-1" {
                    self.downloadData()
                }
                else {
                    loadNewCategory()
                }
            }
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        } else if (Utilities.sharedInstance.getBoolForKey(IS_FROM_SPOTLIGHT)) {
            
            if (self.navigationController?.topViewController?.isKindOfClass(FeedViewController) == true) {
                isBookmarked = true
                createNavTitle()
                Utilities.sharedInstance.setBoolForKey(false, key: IS_FROM_SPOTLIGHT)
                self.bookmarks = CoreDataManager.getBookmarkFeeds()
                self.tableView.reloadData()
                loadArticle()
            }
        }
    }
    
    func loadArticle() {
        var isMatched = false
        var row = -1
        let link_id : String! = Utilities.sharedInstance.getStringForKey(LINK_ID)
        if link_id != nil && link_id != "-1" {
            for feed : BookmarkFeed in self.bookmarks {
                row = row + 1
                let id = Int(link_id)!
                if feed.id == id {
                    isMatched = true
                    break
                }
            }
        }
        
        if isMatched == true {
            if link_id != "-1" {
                Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
                self.isLinkIDMatched = false
                self.rowID = row
                self.performSegueWithIdentifier("ArticleVC", sender: self)
            }
        }
    }
    
    func createNavTitle() {
        
        if isBookmarked == false {
            let navTitleView : UIView = UIView(frame: CGRectMake(0, 0, 90, 30))
            
            navTitle = UILabel(frame: CGRectMake(0, 0, 80, 30))
            navTitle.text = "Your Feed"
            navTitle.textAlignment = NSTextAlignment.Center
            navTitle.font = UIFont(name: "OpenSans", size: 16.0)
            
            navTitleView.addSubview(navTitle)
            
            self.navigationItem.titleView = navTitleView
        } else {
            navTitle.frame = CGRectMake(-10, 0, 110, 30)
            navTitle.text = "Saved Articles"
        }
    }
    
    func createTableViewHeader(){
        let headerView : UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 75))
        
        let font = UIFont(name: "OpenSans", size: 12.0)
        
        customSegmentedControl = UISegmentedControl (items: ["ALL NEWS","UNREAD"])
        customSegmentedControl.setTitleTextAttributes([NSFontAttributeName:font!], forState: UIControlState.Normal)
        customSegmentedControl.frame = CGRectMake(self.view.frame.size.width/2 - 140, 20,280, 35)
        customSegmentedControl.selectedSegmentIndex = 0
        customSegmentedControl.tintColor = UIColor.lightGrayColor()
        customSegmentedControl.addTarget(self, action: "segmentedValueChanged:", forControlEvents: .ValueChanged)
        headerView.addSubview(customSegmentedControl)
        
        self.tableView.tableHeaderView = headerView
    }
    
    // segemented control call back
    func segmentedValueChanged(sender:UISegmentedControl!)
    {
        if sender.selectedSegmentIndex == 0 {
            isUnreadTab = false
            unreadFeeds = []
            self.tableView.reloadData()
        } else {
            isUnreadTab = true
            self.tableView.reloadData()
        }
    }
    
    func downloadData() {
        
        if isPullToRefresh == false || Utilities.sharedInstance.getBoolForKey(IS_FROM_PUSH) == true {
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
        }
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            print("auth_token : \(Utilities.sharedInstance.getAuthToken(AUTH_TOKEN))")
            let parameters = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(FEED_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        self.isPullToRefresh = false
                        SVProgressHUD.dismiss()
                        self.refreshCntrl.endRefreshing()
                        Feeds.sharedInstance.populateFeeds(processedData.objectForKey("links") as! [AnyObject])
                        self.feeds.removeAll(keepCapacity: false)
                        self.unreadFeeds.removeAll(keepCapacity: false)
                        
                        self.isBookmarked = false
                        self.navTitle.text = "Your Feed"
                        self.navTitle.frame = CGRectMake(0, 0, 80, 30)
                        
                        self.feeds = Feeds.sharedInstance.getFeeds()
                        
                        let link_id : String! = Utilities.sharedInstance.getStringForKey(LINK_ID)
                        var row = -1
                        if link_id != "-1" {
                            if  link_id != nil {
                                
                                for feed : InformerlyFeed in self.feeds {
                                    row = row + 1
                                    let id = Int(link_id)!
                                    
                                    if feed.id == id {
                                        self.isFromFeeds = true
                                        self.isLinkIDMatched = true
                                        break
                                    }
                                }
                            }
                        }
                    
                        self.tableView.reloadData()
                        self.tableView.layoutIfNeeded()

                        if self.isLinkIDMatched == false {
                            if link_id != "-1" {
                                // From Custom URL or from old notification
                                self.isFromFeeds = false
                                if link_id == "-2" {
                                    self.downloadArticleData(Utilities.sharedInstance.getStringForKey(SLUG)!)
                                } else {
                                    self.downloadArticleData(link_id)
                                }
                                
                            }
                        } else {
                            if link_id != "-1" {
                                Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
                                self.isLinkIDMatched = false
                                self.rowID = row
                                self.performSegueWithIdentifier("ArticleVC", sender: self)
                            }
                        }
                        
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    self.menu.enabled = true
                    SVProgressHUD.dismiss()
                    self.refreshCntrl.endRefreshing()
                    
                    if extraInfo != nil {
                        var error : [String:AnyObject] = extraInfo as! Dictionary
                        let message : String = error["error"] as! String
                        
                        if message == "Invalid authentication token." || requestStatus == 401 {
                            
                            Utilities.sharedInstance.setBoolAppGroupForKey(false, key: IS_USER_LOGGED_IN)
                            Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                            
                            let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                                self.showViewController(loginVC, sender: self)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            self.showAlert("Error !", msg: message)
                        }
                    } else {
//                        self.showAlert("Error !", msg: "Try Again!")
                    }
            }
        } else {
            SVProgressHUD.dismiss()
            self.refreshCntrl.endRefreshing()
            self.showAlert("No Signal?  Don't worry!", msg: "You can still read your Saved Articles from the side menu.")
        }
    }
    
    
    func downloadArticleData(articleID : String) {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let parameters = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath("links/\(articleID)",
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    var data : [String:AnyObject] = processedData.objectForKey("link") as! Dictionary
                    
                    self.feedData = InformerlyFeed()
                    self.feedData.id = data["id"] as? Int
                    self.feedData.title = data["title"] as? String
                    self.feedData.feedDescription = data["description"] as? String
                    self.feedData.content = data["content"] as? String
                    self.feedData.readingTime = data["reading_time"] as? Int
                    self.feedData.source = data["source"] as? String
                    self.feedData.sourceColor = data["source_color"] as? String
                    self.feedData.URL = data["url"] as? String
                    self.feedData.read = data["read"] as? Bool
                    self.feedData.bookmarked = data["bookmarked"] as? Bool
                    self.feedData.publishedAt = data["published_at"] as? String
                    self.feedData.originalDate = data["original_date"] as? String
                    self.feedData.shortLink = data["shortLink"] as? String
                    self.feedData.slug = data["slug"] as? String
                    
                    Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
                    self.performSegueWithIdentifier("ArticleVC", sender: self)
            }, failure: { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                
                if extraInfo != nil {
                    var error : [String:AnyObject] = extraInfo as! Dictionary
                    let message : String = error["error"] as! String
                    
                    if message == "Invalid authentication token." || requestStatus == 401 {
                        
                        Utilities.sharedInstance.setBoolAppGroupForKey(false, key: IS_USER_LOGGED_IN)
                        Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                        
                        let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                            self.showViewController(loginVC, sender: self)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.showAlert("Error !", msg: message)
                    }
                }
                
            })
            
        }
    }
    
    // TableView delegates and Data source methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isUnreadTab == true && isBookmarked == false && isCategoryFeeds == false {
            unreadFeeds = []
            for feed in self.feeds {
                if feed.read == false {
                    unreadFeeds.append(feed)
                }
            }
            return unreadFeeds.count
        }
        else if isUnreadTab == true && isBookmarked == true {
            unreadBookmarkFeeds = []
            for feed in self.bookmarks {
                if feed.read == false {
                    unreadBookmarkFeeds.append(feed)
                }
            }
            return unreadBookmarkFeeds.count
        }
        else if isBookmarked == true {
            return bookmarks.count
        } else if isCategoryFeeds == true && isUnreadTab == true {
            unreadFeeds = []
            for feed in self.categoryFeeds! {
                if feed.read == false {
                    unreadFeeds.append(feed)
                }
            }
            return unreadFeeds.count
        } else if isCategoryFeeds == true {
            return self.categoryFeeds!.count
        }
        return feeds.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if isUnreadTab == true && isBookmarked == false  {
            return self.getTextHeight(unreadFeeds[indexPath.row].title!, width: width) + CGFloat(68)
        } else if isUnreadTab == true && isBookmarked == true {
            return self.getTextHeight(unreadBookmarkFeeds[indexPath.row].title!, width: width) + CGFloat(68)
        } else if isBookmarked == true {
            return self.getTextHeight(bookmarks[indexPath.row].title!, width: width) + CGFloat(68)
        } else if isUnreadTab == true && isCategoryFeeds == true {
            return self.getTextHeight(unreadFeeds[indexPath.row].title!, width: width) + CGFloat(68)
        } else if isCategoryFeeds == true {
            return self.getTextHeight(categoryFeeds![indexPath.row].title!, width: width) + CGFloat(68)
        }
        return self.getTextHeight(feeds[indexPath.row].title!, width: width) + CGFloat(68)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : MGSwipeTableCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! MGSwipeTableCell
        cell.delegate = self
        cell.separatorInset = UIEdgeInsetsZero
        
        var imgName = ICON_BOOKMARK
//        var tickImgName = ICON_CHECK_CIRCLE_GREY
        let crossImgName = ICON_CROSS
        
        let source = cell.viewWithTag(1) as! UILabel
        let title = cell.viewWithTag(2) as! UILabel
        let readingTime = cell.viewWithTag(3) as! UILabel
        let tick = cell.viewWithTag(4) as! UIImageView
        let bookmarkImg = cell.viewWithTag(5) as! UIImageView
        bookmarkImg.alpha = 0.0
        
        var feed : InformerlyFeed;
        if isUnreadTab == true && isBookmarked == false {
            feed = unreadFeeds[indexPath.row]
            source.text = feed.source
            source.textColor = UIColor(rgba: feed.sourceColor!)
            title.text = feed.title
            
            if feed.read != true {
                title.textColor = UIColor.blackColor()
                
                if feed.readingTime != nil{
                    readingTime.text = "\(String(feed.readingTime!)) min read"
                    tick.image = UIImage(named: ICON_CLOCK)
                }
            } else {
                title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
                readingTime.text = "Read"
                tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
//                tickImgName = ICON_CHECK_CIRCLE
            }
            
            if feed.bookmarked == true {
                imgName = ICON_BOOKMARK_FILLED
                bookmarkImg.alpha = 1.0
            }
            
        } else if isUnreadTab == true && isBookmarked == true {
            var feed : BookmarkFeed
            feed = unreadBookmarkFeeds[indexPath.row]
            source.text = feed.source
            source.textColor = UIColor(rgba: feed.sourceColor!)
            title.text = feed.title
            title.textColor = UIColor.blackColor()
            
            if feed.read != true {
                if feed.readingTime != nil {
                    readingTime.text = "\(feed.readingTime!) min read"
                    tick.image = UIImage(named: ICON_CLOCK)
                }
            } else {
                title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
                readingTime.text = "Read"
                tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
//                tickImgName = ICON_CHECK_CIRCLE
            }
            
            if feed.bookmarked == true {
                imgName = ICON_BOOKMARK_FILLED
                bookmarkImg.alpha = 1.0
            }
            
        } else if isBookmarked == true {
            var feed : BookmarkFeed
            feed = bookmarks[indexPath.row]
            source.text = feed.source
            source.textColor = UIColor(rgba: feed.sourceColor!)
            title.text = feed.title
            title.textColor = UIColor.blackColor()
            
            if feed.read != true {
                
                if feed.readingTime != nil{
                    readingTime.text = "\(feed.readingTime!) min read"
                    tick.image = UIImage(named: ICON_CLOCK)
                }
            } else {
                title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
                readingTime.text = "Read"
                tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
//                tickImgName = ICON_CHECK_CIRCLE
            }
            
            if feed.bookmarked == true {
                imgName = ICON_BOOKMARK_FILLED
                bookmarkImg.alpha = 1.0
            }
            
        } else if isCategoryFeeds == true {
            feed = categoryFeeds![indexPath.row]
            source.text = feed.source
            source.textColor = UIColor(rgba: feed.sourceColor!)
            title.text = feed.title
            
            if feed.read != true {
                title.textColor = UIColor.blackColor()
                
                if feed.readingTime != nil{
                    readingTime.text = "\(String(feed.readingTime!)) min read"
                    tick.image = UIImage(named: ICON_CLOCK)
                }
            } else {
                title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
                readingTime.text = "Read"
                tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
//                tickImgName = ICON_CHECK_CIRCLE
            }
            
            if feed.bookmarked == true {
                imgName = ICON_BOOKMARK_FILLED
                bookmarkImg.alpha = 1.0
            }
        }
        
        else {
            feed = feeds[indexPath.row]
            source.text = feed.source
            source.textColor = UIColor(rgba: feed.sourceColor!)
            title.text = feed.title
            
            if feed.read != true {
                title.textColor = UIColor.blackColor()
                
                if feed.readingTime != nil{
                    readingTime.text = "\(String(feed.readingTime!)) min read"
                    tick.image = UIImage(named: ICON_CLOCK)
                }
            } else {
                title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
                readingTime.text = "Read"
                tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
//                tickImgName = ICON_CHECK_CIRCLE
            }
            
            if feed.bookmarked == true {
                imgName = ICON_BOOKMARK_FILLED
                bookmarkImg.alpha = 1.0
            }
        }
        
        // Create Cell Swipe view
        let bookmarkimage = UIImage(named: imgName)
        let crossImage = UIImage(named: crossImgName)
//        let tickImage = UIImage(named: tickImgName)
        self.bookmarkBtn = MGSwipeButton(title: "",icon: bookmarkimage,backgroundColor:UIColor(rgba:SWIPE_CELL_BACKGROUND),callback:nil)
        bookmarkBtn.buttonWidth = self.view.frame.size.width/3
        
//        self.readBtn = MGSwipeButton(title: "",icon: tickImage, backgroundColor: UIColor(rgba:SWIPE_CELL_BACKGROUND), callback: nil)
//        self.readBtn.buttonWidth = self.view.frame.size.width/3
        
        self.crossBtn = MGSwipeButton(title: "",icon: crossImage, backgroundColor: UIColor(rgba:SWIPE_CELL_BACKGROUND), callback: nil)
        self.crossBtn.buttonWidth = self.view.frame.size.width/3
        
        let shareBtn = MGSwipeButton(title: "", icon: UIImage(named: ICON_SHARE)!, backgroundColor: UIColor(rgba:SWIPE_CELL_BACKGROUND),callback: nil)
        shareBtn.buttonWidth = self.view.frame.size.width/3
        
        cell.rightButtons = [shareBtn,bookmarkBtn,crossBtn]
        cell.rightSwipeSettings.transition = MGSwipeTransition.Border

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.rowID = indexPath.row
        let cell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let title = cell.viewWithTag(2)as! UILabel
        title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
        
        let read = cell.viewWithTag(3) as! UILabel
        read.text = "Read"
        
        let tick = cell.viewWithTag(4) as! UIImageView
        tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
        
        if isBookmarked == true {
            CoreDataManager.updateReadStatusForFeedID(self.bookmarks[indexPath.row].id!, readStatus: true)
        }
        
        self.performSegueWithIdentifier("ArticleVC", sender: self)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func getTextHeight(pString: String, width: CGFloat) -> CGFloat {
        let font : UIFont = UIFont(name: "OpenSans", size: 18.0)!
        let constrainedSize: CGSize = CGSizeMake(width, 9999);
        let attributesDictionary = NSDictionary(object: font, forKey: NSFontAttributeName)
        
        let string = NSMutableAttributedString(string: pString, attributes: attributesDictionary as? [String : AnyObject])
        
        let requiredHeight: CGRect = string.boundingRectWithSize(constrainedSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return requiredHeight.size.height
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ArticleVC" {
            let articleVC : ArticleViewController = segue.destinationViewController as! ArticleViewController
            articleVC.feedData = self.feedData
            articleVC.isFromFeeds = self.isFromFeeds
            articleVC.articleIndex = rowID
            articleVC.isUnreadTab = self.isUnreadTab
            articleVC.isBookmarked = self.isBookmarked
            articleVC.isCategoryFeeds = self.isCategoryFeeds
            if isUnreadTab == true && isBookmarked == false {
                articleVC.unreadFeeds = self.unreadFeeds
            } else if isCategoryFeeds == true {
                articleVC.categoryFeeds = self.categoryFeeds!
            } else {
                articleVC.unreadbookmarkedFeeds = self.unreadBookmarkFeeds
            }
        }
    }
    
    func onMenuPressed() {
        //Mixpanel track
        
        let properties : [String:String] = ["userID":userID,"Email":email]
        Mixpanel.sharedInstance().track("Menu Press", properties: properties)
        self.mm_drawerController.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func onPullToRefresh(sender:AnyObject) {
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            isPullToRefresh = true
            if Utilities.sharedInstance.getBoolForKey(IS_FROM_PUSH) == true {
                
                let properties : [String:String] = ["userID":userID,"Email":email,"Feed Name": "Your Feed"]
                
                // MixPanel track
                Mixpanel.sharedInstance().track("In Feed - Pull to Refresh", properties: properties)
                
                self.downloadData()
                
            } else if isBookmarked == false && isCategoryFeeds == false {
                
                // MixPanel track
                let properties : [String:String] = ["userID":userID,"Email":email,"Feed Name": "Your Feed"]
                Mixpanel.sharedInstance().track("In Feed - Pull to Refresh", properties: properties)
                
                self.downloadData()
                
            } else if isBookmarked == true {
                self.onBookmark()
            } else if isCategoryFeeds == true {
                self.downloadCategory(categoryID,categoryName: categoryName)
            }
        } else {
            self.refreshCntrl.endRefreshing()
        }
    }
    
    func downloadBookmark(completion: (result: Bool) -> Void){
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        self.refreshCntrl.endRefreshing()
                        
                        CoreDataManager.addBookmarkFeeds(processedData.objectForKey("links") as! [AnyObject], isSynced: true)
                        self.bookmarks = CoreDataManager.getBookmarkFeeds()
                        self.appDelegate.addBookmarkedItemsToSpotlight()
                        
                        completion(result: true)
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    completion(result: false)
            }
        }

    }
    
    func onBookmark(){
        
        if isPullToRefresh == true {
            self.downloadBookmark({ (result) -> Void in
                //Mixpanel track
                let properties : [String:String] = ["userID":self.userID,"Email":self.email,"Feed Name": "Bookmarked"]
                Mixpanel.sharedInstance().track("In Feed - Pull to Refresh", properties: properties)
                self.bookmarks = CoreDataManager.getBookmarkFeeds()
                self.tableView.reloadData()
            })
            isPullToRefresh = false
        } else {
            self.isBookmarked = true
            self.createNavTitle()
            self.bookmarks = CoreDataManager.getBookmarkFeeds()
            self.tableView.reloadData()
        }
        
    }
    
    func fetchUserPreferences(){
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let parameters : [String:AnyObject] = ["auth_token":auth_token]

            NetworkManager.sharedNetworkClient().processGetRequestWithPath(USER_PREFERENCE_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        self.refreshCntrl.endRefreshing()
                        print(processedData["preferences"])
                        let preferencesArray : [AnyObject]? = processedData.objectForKey("preferences") as? [AnyObject]
                        if preferencesArray != nil && preferencesArray?.count > 0 {

                            for object : AnyObject in preferencesArray! {
                                var preferences : [String:AnyObject] = object as! [String:AnyObject]

                                if preferences["name"]! as! String == DEFAULT_ARTICLE_VIEW {
                                    Utilities.sharedInstance.setStringForKey(preferences["value"]! as! String, key: DEFAULT_ARTICLE_VIEW)
                                }
                                else if preferences["name"]! as! String == DEFAULT_LIST {
                                    Utilities.sharedInstance.setStringForKey(preferences["value"]! as! String, key: DEFAULT_LIST)

                                    if preferences["value"]! as! String == "unread" {
                                        self.isUnreadTab = true
                                        self.customSegmentedControl.selectedSegmentIndex = 1
                                    }
                                }
                            }
                        } else {
                            Utilities.sharedInstance.setStringForKey("web", key: DEFAULT_ARTICLE_VIEW)
                            Utilities.sharedInstance.setStringForKey("all", key: DEFAULT_LIST)
                        }
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    print("Error")
                    
                    if extraInfo != nil {
                        var error : [String:AnyObject] = extraInfo as! Dictionary
                        let message : String = error["error"] as! String
                        
                        if message == "Invalid authentication token." || requestStatus == 401 {
                            
                            Utilities.sharedInstance.setBoolAppGroupForKey(false, key: IS_USER_LOGGED_IN)
                            Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                            
                            let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                                self.showViewController(loginVC, sender: self)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            self.showAlert("Error !", msg: message)
                        }
                    }
            }
        }
    }
    
    
    func onUpdateYourInterest(){
//        self.performSegueWithIdentifier("UpdateInterestsVC", sender: self)
        Intercom.presentMessageComposer()
    }
    
    // Notication selectors
    @objc func yourFeedNotificationSelector(notification: NSNotification){
        self.isBookmarked = false
        self.isCategoryFeeds = false
        self.navTitle.text = "Your Feed"
        self.navTitle.frame = CGRectMake(0, 0, 80, 30)
        
        if self.feeds.count == 0 {
            self.downloadData()
        } else {
            self.tableView.reloadData()
        }
    }
    
    @objc func bookmarkNotificationSelector(notification: NSNotification){
        self.isCategoryFeeds = false
        self.onBookmark()
    }
    
    @objc func categoryNotificationSelector(notification: NSNotification) {
        
        self.isBookmarked = false
        self.isCategoryFeeds = true
        
        if Utilities.sharedInstance.getStringForKey(FEED_ID) != "-1" {
            Utilities.sharedInstance.setStringForKey("-1", key: FEED_ID)
        }
        
        var dict  = notification.userInfo as! Dictionary<String,String>
        self.categoryID = Int(dict["id"]!)!
        self.categoryName = dict["name"]!
        
        self.downloadCategory(categoryID,categoryName: categoryName)
    }
    
    @objc func settingsNotificationSelector(notification: NSNotification) {
        let settingsVC: SettingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsVC") as! SettingsViewController
        self.navigationController?.showViewController(settingsVC, sender: self)
    }
    
    
    func downloadCategory(categoryID : Int, categoryName:String){
        
        if Utilities.sharedInstance.isConnectedToNetwork() == false && CategoryFeeds.sharedInstance.getCategoryFeeds(categoryID) == nil{
            SVProgressHUD.dismiss()
            self.refreshCntrl.endRefreshing()
            self.isCategoryFeeds = false
            self.showAlert("No Signal?  Don't worry!", msg: "You can still read your Saved Articles from the side menu.")
            return
        }
        
        self.categoryFeeds = CategoryFeeds.sharedInstance.getCategoryFeeds(categoryID)
        if  self.categoryFeeds == nil || self.categoryFeeds!.isEmpty || isPullToRefresh == true {
            
            if Utilities.sharedInstance.isConnectedToNetwork() == true {
                if isPullToRefresh == false {
                    SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
                }
                
                isPullToRefresh = false
                
                let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
                let parameters = ["auth_token":auth_token,
                "content":"true"]
                let URL = "\(FEED_URL)/\(categoryID)"
                
                NetworkManager.sharedNetworkClient().processGetRequestWithPath(URL,
                    parameter: parameters,
                    success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                        
                        if requestStatus == 200 {
                            
                            //MixPanel track
                            let properties : [NSObject : AnyObject] = ["UserID":self.userID,"Email":self.email, "Feed ID":categoryID,"Feed Name": categoryName]
                            Mixpanel.sharedInstance().track("In Feed - Pull to Refresh", properties: properties)
                            
                            SVProgressHUD.dismiss()
                            self.refreshCntrl.endRefreshing()
                            self.navTitle.text = categoryName
                            
                            CategoryFeeds.sharedInstance.populateFeeds(processedData.objectForKey("links") as! [AnyObject], categoryID: categoryID)
                            self.categoryFeeds = CategoryFeeds.sharedInstance.getCategoryFeeds(categoryID)
                            let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
                            var row = -1
                            for feed : InformerlyFeed in self.categoryFeeds! {
                                row = row + 1
                                if feed.id == userDefaults.integerForKey(CATEGORY_FEED_ARTICLE_ID) {
                                    self.rowID = row
                                    userDefaults.setInteger(-1, forKey: CATEGORY_FEED_ARTICLE_ID)
                                    userDefaults.synchronize()
                                    self.tableView.reloadData()
                                    self.performSegueWithIdentifier("ArticleVC", sender: self)
                                }
                            }
                            
                            self.tableView.reloadData()
                        }
                    }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                        self.menu.enabled = true
                        SVProgressHUD.dismiss()
                        self.refreshCntrl.endRefreshing()
                        
                        if extraInfo != nil {
                            var error : [String:AnyObject] = extraInfo as! Dictionary
                            let message : String = error["error"] as! String
                            
                            if message == "Invalid authentication token." || requestStatus == 401 {
                                
                                Utilities.sharedInstance.setBoolAppGroupForKey(false, key: IS_USER_LOGGED_IN)
                                Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                                
                                let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                                    self.showViewController(loginVC, sender: self)
                                }))
                                self.presentViewController(alert, animated: true, completion: nil)
                            } else {
                                self.showAlert("Error !", msg: message)
                            }
                        }
                }
            } else {
                SVProgressHUD.dismiss()
                self.refreshCntrl.endRefreshing()
                self.showAlert("No Signal?  Don't worry!", msg: "You can still read your Saved Articles from the side menu.")
            }
        } else {
            self.navTitle.text = categoryName
            self.categoryFeeds = CategoryFeeds.sharedInstance.getCategoryFeeds(categoryID)
            self.tableView.reloadData()
        }
    }
    
    func showAlert(title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func onSharePressed(indexPath:Int) {
        var sharingItems = [AnyObject]()
        var url : NSURL!
        if isBookmarked == true {
            
            if isUnreadTab == true {
                sharingItems.append(self.unreadBookmarkFeeds[indexPath].title!)
                url = NSURL(string: unreadBookmarkFeeds[indexPath].url!)
                sharingItems.append(url)
            } else {
                sharingItems.append(self.bookmarks[indexPath].title!)
                url = NSURL(string: bookmarks[indexPath].url!)
                sharingItems.append(url)
            }
            
        } else if isCategoryFeeds == true {
            
            if isUnreadTab == true {
                sharingItems.append(self.unreadFeeds[indexPath].title!)
                url = NSURL(string: self.unreadFeeds[indexPath].URL!)
                sharingItems.append(url)
            } else {
                sharingItems.append(self.categoryFeeds![indexPath].title!)
                url = NSURL(string: self.categoryFeeds![indexPath].URL!)
                sharingItems.append(url)
            }
        } else {
            
            if isUnreadTab == true {
                sharingItems.append(self.unreadFeeds[indexPath].title!)
                url = NSURL(string: self.unreadFeeds[indexPath].URL!)
                sharingItems.append(url)
            } else {
                sharingItems.append(feeds[indexPath].title!)
                url = NSURL(string: feeds[indexPath].URL!)
                sharingItems.append(url)
            }
        }
        
        let activity = ARSafariActivity()
        let activityVC = UIActivityViewController(activityItems:sharingItems, applicationActivities: [activity])
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func onBookmarkPressed(indexPath:NSIndexPath,bookmarkBtn:MGSwipeButton) {
        
        let cell : MGSwipeTableCell = self.tableView.cellForRowAtIndexPath(indexPath) as! MGSwipeTableCell
        let bookmarkImg = cell.viewWithTag(5) as! UIImageView
        
        if isBookmarked == true {
            if isUnreadTab == true {
                if self.unreadBookmarkFeeds[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK)!, forState: UIControlState.Normal)
                    bookmarkImg.alpha = 0.0
                    self.unreadBookmarkFeeds[indexPath.row].bookmarked = false
                    self.markAsBookmarked(self.unreadBookmarkFeeds[indexPath.row].id!,feed: self.unreadBookmarkFeeds[indexPath.row],indexPath: indexPath)
//                    CoreDataManager.removeBookmarkFeedOfID(self.unreadBookmarkFeeds[indexPath.row].id!)
//                    self.bookmarks = CoreDataManager.getBookmarkFeeds()
                    self.unreadBookmarkFeeds.removeAll(keepCapacity: false)
                    
                    for feed in self.bookmarks {
                        if feed.read == false {
                            self.unreadBookmarkFeeds.append(feed)
                        }
                    }
                    
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.tableView.endUpdates()
                } else {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
                    bookmarkImg.alpha = 1.0
                    self.bookmarks[indexPath.row].bookmarked = true
                    self.markAsBookmarked(self.bookmarks[indexPath.row].id!,feed: self.bookmarks[indexPath.row],indexPath: indexPath)
                }
            } else {
                
                if self.bookmarks[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK)!, forState: UIControlState.Normal)
                    self.bookmarks[indexPath.row].bookmarked = false
                    bookmarkImg.alpha = 0.0
                    self.markAsBookmarked(self.bookmarks[indexPath.row].id!,feed: self.bookmarks[indexPath.row],indexPath: indexPath)
//                    CoreDataManager.removeBookmarkFeedOfID(self.bookmarks[indexPath.row].id!)
//                    self.bookmarks = CoreDataManager.getBookmarkFeeds()
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.tableView.endUpdates()
                } else {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
                    self.bookmarks[indexPath.row].bookmarked = true
                    bookmarkImg.alpha = 0.0
                    self.markAsBookmarked(self.bookmarks[indexPath.row].id!,feed: self.bookmarks[indexPath.row],indexPath: indexPath)
                }
            }

        } else if isCategoryFeeds == true {
            
            if isUnreadTab == true {
                if self.unreadFeeds[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK)!, forState: UIControlState.Normal)
                    self.unreadFeeds[indexPath.row].bookmarked = false
                    bookmarkImg.alpha = 0.0
                } else {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
                    bookmarkImg.alpha = 1.0
                    self.unreadFeeds[indexPath.row].bookmarked = true
                }
                
                self.markAsBookmarked(self.unreadFeeds[indexPath.row].id!,feed: self.unreadFeeds[indexPath.row],indexPath: indexPath)
            } else {
                if self.categoryFeeds![indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK)!, forState: UIControlState.Normal)
                    self.categoryFeeds![indexPath.row].bookmarked = false
                    bookmarkImg.alpha = 0.0
                } else {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
                    self.categoryFeeds![indexPath.row].bookmarked = true
                    bookmarkImg.alpha = 1.0
                }
                
                self.markAsBookmarked(self.categoryFeeds![indexPath.row].id!,feed: self.categoryFeeds![indexPath.row],indexPath: indexPath)
            }

        } else {
            
            if isUnreadTab == true {
                if self.unreadFeeds[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK)!, forState: UIControlState.Normal)
                    self.unreadFeeds[indexPath.row].bookmarked = false
                    bookmarkImg.alpha = 0.0
                } else {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
                    self.unreadFeeds[indexPath.row].bookmarked = true
                    bookmarkImg.alpha = 1.0
                }
                
                self.markAsBookmarked(self.unreadFeeds[indexPath.row].id!,feed: self.unreadFeeds[indexPath.row],indexPath: indexPath)
            } else {
                if self.feeds[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK)!, forState: UIControlState.Normal)
                    self.feeds[indexPath.row].bookmarked = false
                    bookmarkImg.alpha = 0.0
                } else {
                    bookmarkBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
                    self.feeds[indexPath.row].bookmarked = true
                    bookmarkImg.alpha = 1.0
                }
                
                self.markAsBookmarked(self.feeds[indexPath.row].id!,feed: self.feeds[indexPath.row],indexPath: indexPath)
            }
        }
    }
    
    func markAsBookmarked(articleID:Int, feed:AnyObject,indexPath:NSIndexPath) {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            
            let parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "link_id":articleID]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        let message = processedData.objectForKey("message") as! String
                        if message == "Bookmark Created" {
                            
                            //Mixpanel track
                            let properties : [String:String] = ["UserID":self.userID,"Email":self.email]
                            Mixpanel.sharedInstance().track("Swipe In-Feed - Save",properties: properties)
                            
                            if self.isBookmarked == true {
                                
                            } else {
                                CoreDataManager.addBookmarkFeed(feed as! InformerlyFeed, isSynced: true)
                                self.bookmarks = CoreDataManager.getBookmarkFeeds()
                                self.appDelegate.addItemToSpotlight(feed as! InformerlyFeed)
                            }
                        } else if message == "Bookmark Removed" {
                            if self.isBookmarked == true {
                                self.bookmarks = CoreDataManager.getBookmarkFeeds()
                                
                                var counter = 0
                                for feed : InformerlyFeed in self.feeds {
                                    if feed.id == articleID {
                                        self.feeds[counter].bookmarked = false
                                        break
                                    }
                                    counter++
                                }
                                self.appDelegate.removeItemFromSpotlight(String(articleID))
                            } else {
                                self.appDelegate.removeItemFromSpotlight(String(articleID))
                                CoreDataManager.removeBookmarkFeedOfID(articleID)
                            }
                        }
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    
                    if extraInfo != nil {
                        var error : [String:AnyObject] = extraInfo as! Dictionary
                        let message : String = error["error"] as! String
                        
                        if message == "Invalid authentication token." || requestStatus == 401 {
                            
                            Utilities.sharedInstance.setBoolAppGroupForKey(false, key: IS_USER_LOGGED_IN)
                            Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                            
                            let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                                self.showViewController(loginVC, sender: self)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            self.showAlert("Error !", msg: message)
                        }
                    }
            }
        } else {
            // Offline mode
            
            if isBookmarked == false {
                let tempFeed : InformerlyFeed = feed as! InformerlyFeed
                if tempFeed.bookmarked == false {
                    CoreDataManager.removeBookmarkFeedOfID(tempFeed.id!)
                } else {
                    CoreDataManager.addBookmarkFeed(feed as! InformerlyFeed, isSynced: false)
                }
                self.bookmarks = CoreDataManager.getBookmarkFeeds()
            } else {
//                CoreDataManager.removeBookmarkFeedOfID(indexPath.row)
                CoreDataManager.unbookmarkFeed(articleID, syncStatus: false)
                
                var allBookmarks : [BookmarkFeed] = []
                allBookmarks = CoreDataManager.getBookmarkFeeds()
                self.bookmarks.removeAll()
                for feed in allBookmarks {
                    if feed.isSynced == true {
                        self.bookmarks.append(feed)
                    }
                }
            }
        }
    }
    
//    func onMarkReadPressed(indexPath:NSIndexPath,readBtn:MGSwipeButton) {
    
//        let cell : MGSwipeTableCell = self.tableView.cellForRowAtIndexPath(indexPath) as! MGSwipeTableCell
//        let title = cell.viewWithTag(2) as! UILabel
//        let readingTime = cell.viewWithTag(3) as! UILabel
//        let tick = cell.viewWithTag(4) as! UIImageView
//        
//        if isBookmarked == true {
//            if isUnreadTab == true {
//                readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE), forState: UIControlState.Normal)
//                markAsRead(indexPath)
//                
//                var counter = 0
//                for feed in self.bookmarks {
//                    if feed.id == unreadBookmarkFeeds[indexPath.row].id {
//                        self.bookmarks[counter].read = true
//                    }
//                    counter++
//                }
//                
//                unreadBookmarkFeeds.removeAtIndex(indexPath.row)
//                self.tableView.beginUpdates()
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//                self.tableView.endUpdates()
//                
//            } else {
//                if self.bookmarks[indexPath.row].read == true {
//                    readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE_GREY), forState: UIControlState.Normal)
//                    markAsUnread(indexPath)
//                    
//                    title.textColor = UIColor.blackColor()
//                    readingTime.text = "\(String(self.bookmarks[indexPath.row].readingTime!)) min read"
//                    tick.image = UIImage(named: ICON_CLOCK)
//                    
//                } else {
//                    readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE), forState: UIControlState.Normal)
//                    markAsRead(indexPath)
//                    
//                    readingTime.text = "Read"
//                    title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
//                    tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
//                }
//            }
//            
//        } else if isCategoryFeeds == true {
//            
//            if isUnreadTab == true {
//                readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE), forState: UIControlState.Normal)
//                markAsRead(indexPath)
//                
//                var counter = 0
//                for feed in self.categoryFeeds! {
//                    if feed.id == unreadFeeds[indexPath.row].id {
//                        self.categoryFeeds![counter].read = true
//                    }
//                    counter++
//                }
//                
//                unreadFeeds.removeAtIndex(indexPath.row)
//                self.tableView.beginUpdates()
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//                self.tableView.endUpdates()
//            
//            } else {
//                if self.categoryFeeds![indexPath.row].read == true {
//                    readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE_GREY), forState: UIControlState.Normal)
//                    markAsUnread(indexPath)
//                    
//                    title.textColor = UIColor.blackColor()
//                    readingTime.text = "\(String(self.categoryFeeds![indexPath.row].readingTime!)) min read"
//                    tick.image = UIImage(named: ICON_CLOCK)
//                    
//                } else {
//                    readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE), forState: UIControlState.Normal)
//                    markAsRead(indexPath)
//                    
//                    title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
//                    readingTime.text = "Read"
//                    tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
//                }
//            }
//            
//        } else {
//            
//            if isUnreadTab == true {
//                readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE), forState: UIControlState.Normal)
//                markAsRead(indexPath)
//                
//                var counter = 0
//                for feed in self.feeds {
//                    if feed.id == unreadFeeds[indexPath.row].id {
//                        self.feeds[counter].read = true
//                    }
//                    counter++
//                }
//                
//                self.unreadFeeds.removeAtIndex(indexPath.row)
//                self.tableView.beginUpdates()
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//                self.tableView.endUpdates()
//            } else {
//                if self.feeds[indexPath.row].read == true {
//                    readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE_GREY), forState: UIControlState.Normal)
//                    markAsUnread(indexPath)
//                    
//                    title.textColor = UIColor.blackColor()
//                    readingTime.text = "\(String(self.feeds[indexPath.row].readingTime!)) min read"
//                    tick.image = UIImage(named: ICON_CLOCK)
//                    
//                } else {
//                    readBtn.setImage(UIImage(named: ICON_CHECK_CIRCLE), forState: UIControlState.Normal)
//                    markAsRead(indexPath)
//                    
//                    title.textColor = UIColor(rgba: CELL_TITLE_COLOR)
//                    readingTime.text = "Read"
//                    tick.image = UIImage(named: ICON_CHECK_CIRCLE_GREY)
//                    
//                }
//            }
//        }
//    }
    
    func onCrossPressed(indexPath:NSIndexPath,crossBtn:MGSwipeButton) {
        
        var articleID : Int!
        var parameters : [String:AnyObject]!
        let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
        let path = "users/\(self.userID)/ignore_link"
        
        if isBookmarked == true {
            
            if isUnreadTab == true {
                articleID = unreadBookmarkFeeds[indexPath.row].id!
                var counter : Int = 0
                for feed in self.bookmarks {
                    if feed.id == self.unreadBookmarkFeeds[indexPath.row].id {
                        self.bookmarks.removeAtIndex(counter)
                        break
                    }
                    counter++
                }
                self.unreadBookmarkFeeds.removeAtIndex(indexPath.row)
            } else {
                articleID = bookmarks[indexPath.row].id!
                self.bookmarks.removeAtIndex(indexPath.row)
            }
            CoreDataManager.removeBookmarkFeedOfID(articleID)
            
        } else if isCategoryFeeds == true {
            
            if isUnreadTab == true {
                articleID = unreadFeeds[indexPath.row].id!
                var counter : Int = 0
                for feed in self.categoryFeeds! {
                    if feed.id == self.unreadFeeds[indexPath.row].id {
                        self.categoryFeeds!.removeAtIndex(counter)
                        break
                    }
                    counter++
                }
                self.unreadFeeds.removeAtIndex(indexPath.row)
            } else {
                articleID = categoryFeeds![indexPath.row].id!
                self.categoryFeeds!.removeAtIndex(indexPath.row)
            }
            
        } else {
            
            if isUnreadTab == true {
                articleID = unreadFeeds[indexPath.row].id!
                var counter : Int = 0
                for feed in self.feeds {
                    if feed.id == self.unreadFeeds[indexPath.row].id {
                        self.feeds.removeAtIndex(counter)
                        break
                    }
                    counter++
                }
                self.unreadFeeds.removeAtIndex(indexPath.row)
            } else {
                articleID = feeds[indexPath.row].id!
                self.feeds.removeAtIndex(indexPath.row)
            }
        }
        
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()
        
        if Utilities.sharedInstance.isConnectedToNetwork() {
            parameters = ["auth_token":auth_token,
                "link_id":articleID]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    print("Successfully removed.")
                    
                    //Mixpanel track
                    let properties : [String:String] = ["userID":self.userID,"Email":self.email]
                    Mixpanel.sharedInstance().track("Swipe In-Feed - Remove",properties: properties)
                    
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    print("Failure removing article")
                    
                    if extraInfo != nil {
                        var error : [String:AnyObject] = extraInfo as! Dictionary
                        let message : String = error["error"] as! String
                        let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            }
        } else {
            var removedArticles:[Int]!
            if NSUserDefaults.standardUserDefaults().objectForKey(REMOVED_ARTICLES) == nil {
                removedArticles = [Int]()
            } else {
                removedArticles = NSUserDefaults.standardUserDefaults().objectForKey(REMOVED_ARTICLES) as! Array
            }
            removedArticles.append(articleID)
            
            NSUserDefaults.standardUserDefaults().setObject(removedArticles, forKey: REMOVED_ARTICLES)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    
    func markAsRead(indexPath:NSIndexPath){
        var path : String!
        var articleID : Int!
        
        if isBookmarked == true {
            
            if isUnreadTab == true {
                
                path = "links/\(unreadBookmarkFeeds[indexPath.row].id!)/read"
                articleID = unreadBookmarkFeeds[indexPath.row].id!
            } else {
                self.bookmarks[indexPath.row].read = true
                path = "links/\(bookmarks[indexPath.row].id!)/read"
                articleID = bookmarks[indexPath.row].id!
            }
            
        } else if isCategoryFeeds == true {
            
            if isUnreadTab == true {
                self.unreadFeeds[indexPath.row].read = true
                path = "links/\(unreadFeeds[indexPath.row].id!)/read"
                articleID = unreadFeeds[indexPath.row].id!
            } else {
                self.categoryFeeds![indexPath.row].read = true
                path = "links/\(categoryFeeds![indexPath.row].id!)/read"
                articleID = categoryFeeds![indexPath.row].id!
            }
        
        } else {
            
            if isUnreadTab == true {
                self.unreadFeeds[indexPath.row].read = true
                path = "links/\(unreadFeeds[indexPath.row].id!)/read"
                articleID = unreadFeeds[indexPath.row].id!
            } else {
                self.feeds[indexPath.row].read = true
                path = "links/\(feeds[indexPath.row].id!)/read"
                articleID = feeds[indexPath.row].id!
            }
        }
        
        let parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
            "client_id":"",
            "link_id": articleID]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                print("Successfully marked as read.")
                
                //Mixpanel track
                let properties : [String:String] = ["userID":self.userID,"Email":self.email]
                Mixpanel.sharedInstance().track("Swipe In-Feed - Read",properties: properties)
                
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                print("Failure marking article as read")
                
                var readArticles:[Int]!
                if NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) == nil {
                    readArticles = [Int]()
                } else {
                    readArticles = NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) as! Array
                }
                if self.isBookmarked == true {
                    
                    if self.isUnreadTab == true {
                        readArticles.append(self.unreadBookmarkFeeds[indexPath.row].id!)
                    } else {
                        readArticles.append(self.bookmarks[indexPath.row].id!)
                    }
                    
                } else {
                    
                    if self.isUnreadTab == true {
                        readArticles.append(self.unreadFeeds[indexPath.row].id!)
                    } else {
                        readArticles.append(self.feeds[indexPath.row].id!)
                    }
                }
                
                NSUserDefaults.standardUserDefaults().setObject(readArticles, forKey: READ_ARTICLES)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                if extraInfo != nil {
                    var error : [String:AnyObject] = extraInfo as! Dictionary
                    let message : String = error["error"] as! String
                    
                    if message == "Invalid authentication token." || requestStatus == 401 {
                        
                        Utilities.sharedInstance.setBoolAppGroupForKey(false, key: IS_USER_LOGGED_IN)
                        Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                        let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                            self.showViewController(loginVC, sender: self)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
        }
    }
    
    func markAsUnread(indexPath:NSIndexPath){
        var path : String!
        var articleID : Int!
        
        if isBookmarked == true {
            self.bookmarks[indexPath.row].read = false
            path = "links/\(bookmarks[indexPath.row].id!)/mark_as_unread"
            articleID = bookmarks[indexPath.row].id!
        } else if isCategoryFeeds == true {
            self.categoryFeeds![indexPath.row].read = false
            path = "links/\(categoryFeeds![indexPath.row].id!)/mark_as_unread"
            articleID = categoryFeeds![indexPath.row].id!
        } else {
            self.feeds[indexPath.row].read = false
            path = "links/\(feeds[indexPath.row].id!)/mark_as_unread"
            articleID = feeds[indexPath.row].id!
        }
        
        let parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
            "link_id": articleID]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                print("Successfully marked as unread.")
                
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                print("Failure marking article as unread")
                
                if extraInfo != nil {
                    var error : [String:AnyObject] = extraInfo as! Dictionary
                    let message : String = error["error"] as! String
                    
                    if message == "Invalid authentication token." || requestStatus == 401 {
                        
                        Utilities.sharedInstance.setBoolAppGroupForKey(false, key: IS_USER_LOGGED_IN)
                        Utilities.sharedInstance.setBoolForKey(false, key: IS_USER_LOGGED_IN)
                        
                        let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                            self.showViewController(loginVC, sender: self)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.showAlert("Error !", msg: message)
                    }
                }
        }
        
    }
    
    // Swipe Cell delegates
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        let indexPath : NSIndexPath = self.tableView.indexPathForCell(cell)!
        if index == 0 {
            //Mixpanel track
            let properties : [String:String] = ["userID":userID,"Email":email]
            Mixpanel.sharedInstance().track("Swipe In-Feed - Share", properties: properties)
            self.onSharePressed(indexPath.row)
            return true
        } else if index == 1 {
            let btn = cell.rightButtons[1] as! MGSwipeButton
            self.onBookmarkPressed(indexPath,bookmarkBtn: btn)
            return true
        } else {
            let btn = cell.rightButtons[2] as! MGSwipeButton
            self.onCrossPressed(indexPath, crossBtn: btn)
//            self.onMarkReadPressed(indexPath, readBtn: btn)
            return true
        }
    }
    
    func loadNewCategory() {
        self.isBookmarked = false
        self.isCategoryFeeds = true

        let menuItems : [Item] = MenuItems.sharedInstance.getItems()
        var name = ""
        for item : Item in menuItems {
            if item.id == Int(Utilities.sharedInstance.getStringForKey(FEED_ID)!) {
                name = item.name!
            }
        }
        
        self.downloadCategory(Int(Utilities.sharedInstance.getStringForKey(FEED_ID)!)!,categoryName: name)
        Utilities.sharedInstance.setStringForKey("-1", key: FEED_ID)
    }
    
    func createCustomPushAlert() {
        
        let title = "Stay ahead in your industry."
        let msg = "Receive alerts for breaking industry news."
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Not Now", style: UIAlertActionStyle.Cancel, handler: { (sender) -> Void in
            Utilities.sharedInstance.setBoolForKey(false, key: PUSH_ALLOWED)
            Utilities.sharedInstance.setIntForKey(1, key: APP_LAUNCH_COUNTER)
        }))
        alert.addAction(UIAlertAction(title: "Enable", style: UIAlertActionStyle.Default, handler: { (sender) -> Void in
            Utilities.sharedInstance.setBoolForKey(true, key: PUSH_ALLOWED)
            Utilities.sharedInstance.setIntForKey(0, key: APP_LAUNCH_COUNTER)
            let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.configurePushNotification()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}