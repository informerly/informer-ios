//
//  FeedViewController.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class FeedViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {
    
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
    private var customURLData : InformerlyFeed!
    private var bookmarkBtn : MGSwipeButton!
    private var readBtn : MGSwipeButton!
    private var customSegmentedControl : UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Nav bar.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.translucent = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.createNavTitle()
        
        // Adds menu icon on nav bar.
        menu = UIBarButtonItem(image: UIImage(named: "menu_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onMenuPressed"))
        menu.tintColor = UIColor.grayColor()
        self.navigationItem.leftBarButtonItem = menu
        
        // Adds interest icon on nav bar.
        var interestBtn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_interests"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onUpdateYourInterest"))
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
        self.downloadData()
        self.downloadBookmark { (result) -> Void in}
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "yourFeedNotificationSelector:", name:"YourFeedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bookmarkNotificationSelector:", name:"BookmarkNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "categoryNotificationSelector:", name:"CategoryNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "settingsNotificationSelector:", name:"SettingsNotification", object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBar.hidden = false
        
        if isBookmarked == true {
            self.bookmarks = CoreDataManager.getBookmarkFeeds()
        } else {
            self.feeds = Feeds.sharedInstance.getFeeds()
        }
        
//        if Utilities.sharedInstance.getStringForKey(DEFAULT_LIST) == "unread" {
//            self.customSegmentedControl.selectedSegmentIndex = 1
//            self.isUnreadTab = true
//        } else if Utilities.sharedInstance.getStringForKey(DEFAULT_LIST) == "all" {
//            self.customSegmentedControl.selectedSegmentIndex = 0
//            self.isUnreadTab = false
//        }
        
        self.tableView.reloadData()
    }
    
    func createNavTitle() {
        
        if isBookmarked == false {
            var navTitleView : UIView = UIView(frame: CGRectMake(0, 0, 90, 30))
            
            navTitle = UILabel(frame: CGRectMake(0, 0, 80, 30))
            navTitle.text = "Your Feed"
            navTitle.textAlignment = NSTextAlignment.Center
            navTitle.font = UIFont(name: "OpenSans-Regular", size: 14.0)
            
            navTitleView.addSubview(navTitle)
            
            self.navigationItem.titleView = navTitleView
        } else {
            navTitle.frame = CGRectMake(0, 0, 100, 30)
            navTitle.text = "Bookmarked"
        }
    }
    
    func createTableViewHeader(){
        var headerView : UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 75))
        
        customSegmentedControl = UISegmentedControl (items: ["All News","Unread"])
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
        
        if isPullToRefresh == false {
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
        }
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            println(auth_token)
            var parameters = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(FEED_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        self.isPullToRefresh = false
                        SVProgressHUD.dismiss()
                        self.refreshCntrl.endRefreshing()
                        Feeds.sharedInstance.populateFeeds(processedData["links"]as! [AnyObject])
                        self.feeds.removeAll(keepCapacity: false)
                        self.unreadFeeds.removeAll(keepCapacity: false)
                        
                        self.isBookmarked = false
                        self.navTitle.text = "Your Feed"
                        self.navTitle.frame = CGRectMake(0, 0, 80, 30)
                        
                        self.feeds = Feeds.sharedInstance.getFeeds()
                        
                        var link_id : String! = Utilities.sharedInstance.getStringForKey(LINK_ID)
                        var row = -1
                        if link_id != "-1" {
                            var feed : InformerlyFeed!
                            if  link_id != nil {
                                for feed in self.feeds {
                                    row = row + 1
                                    var id : Int = link_id.toInt()!
                                    if feed.id == id {
                                        break
                                    }
                                }
                            }
                        }
                            
                        self.tableView.reloadData()
                        self.tableView.layoutIfNeeded()
                            
                        if link_id != "-1" {
                            
                            if Utilities.sharedInstance.getBoolForKey(IS_FROM_CUSTOM_URL) == true {
                                self.downloadArticleData(link_id)
                            } else {
                                Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
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
                        var message : String = error["error"] as! String
                        
                        if message == "Invalid authentication token." {
                            var alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                                self.showViewController(loginVC, sender: self)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                        self.showAlert("Error !", msg: message)
                    } else {
//                        self.showAlert("Error !", msg: "Try Again!")
                    }
            }
        } else {
            SVProgressHUD.dismiss()
            self.refreshCntrl.endRefreshing()
            self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
        }
    }
    
    
    func downloadArticleData(articleID : String) {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            var parameters = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath("links/\(articleID)",
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    var data : [String:AnyObject] = processedData["link"] as! Dictionary
                    
                    self.customURLData = InformerlyFeed()
                    self.customURLData.id = data["id"] as? Int
                    self.customURLData.title = data["title"] as? String
                    self.customURLData.feedDescription = data["description"] as? String
                    self.customURLData.content = data["content"] as? String
                    self.customURLData.readingTime = data["reading_time"] as? Int
                    self.customURLData.source = data["source"] as? String
                    self.customURLData.sourceColor = data["source_color"] as? String
                    self.customURLData.URL = data["url"] as? String
                    self.customURLData.read = data["read"] as? Bool
                    self.customURLData.bookmarked = data["bookmarked"] as? Bool
                    self.customURLData.publishedAt = data["published_at"] as? String
                    self.customURLData.originalDate = data["original_date"] as? String
                    self.customURLData.shortLink = data["shortLink"] as? String
                    self.customURLData.slug = data["slug"] as? String
                    
                    self.performSegueWithIdentifier("ArticleVC", sender: self)
            }, failure: { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                
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
        
        var imgName = "icon_bookmark"
        var tickImgName = "icon_tick"
        
        var source = cell.viewWithTag(1) as! UILabel
        var title = cell.viewWithTag(2) as! UILabel
        var readingTime = cell.viewWithTag(3) as! UILabel
        var tick = cell.viewWithTag(4) as! UIImageView
        
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
                    tick.image = UIImage(named: "clock_icon")
                }
            } else {
                title.textColor = UIColor(rgba: "#9B9B9B")
                readingTime.text = "Read"
                tick.image = UIImage(named: "icon_tick")
                tickImgName = "icon_check_circle"
            }
            
            if feed.bookmarked == true {
                imgName = "icon_bookmark_filled"
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
                    tick.image = UIImage(named: "clock_icon")
                }
            } else {
//                title.textColor = UIColor(rgba: "#9B9B9B")
                readingTime.text = "Read"
                tick.image = UIImage(named: "icon_tick")
                tickImgName = "icon_check_circle"
            }
            
            if feed.bookmarked == true {
                imgName = "icon_bookmark_filled"
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
                    tick.image = UIImage(named: "clock_icon")
                }
            } else {
//                title.textColor = UIColor(rgba: "#9B9B9B")
                readingTime.text = "Read"
                tick.image = UIImage(named: "icon_tick")
                tickImgName = "icon_check_circle"
            }
            
            if feed.bookmarked == true {
                imgName = "icon_bookmark_filled"
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
                    tick.image = UIImage(named: "clock_icon")
                }
            } else {
                title.textColor = UIColor(rgba: "#9B9B9B")
                readingTime.text = "Read"
                tick.image = UIImage(named: "icon_tick")
                tickImgName = "icon_check_circle"
            }
            
            if feed.bookmarked == true {
                imgName = "icon_bookmark_filled"
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
                    tick.image = UIImage(named: "clock_icon")
                }
            } else {
                title.textColor = UIColor(rgba: "#9B9B9B")
                readingTime.text = "Read"
                tick.image = UIImage(named: "icon_tick")
                tickImgName = "icon_check_circle"
            }
            
            if feed.bookmarked == true {
                imgName = "icon_bookmark_filled"
            }
        }
        
        // Create Cell Swipe view
        var bookmarkimage = UIImage(named: imgName)
        var tickImage = UIImage(named: tickImgName)
        self.bookmarkBtn = MGSwipeButton(title: "",icon: bookmarkimage,backgroundColor:UIColor.whiteColor(),callback:nil)
        bookmarkBtn.buttonWidth = self.view.frame.size.width/3
        
        self.readBtn = MGSwipeButton(title: "",icon: tickImage, backgroundColor: UIColor.whiteColor(), callback: nil)
        self.readBtn.buttonWidth = self.view.frame.size.width/3
        
        var shareBtn = MGSwipeButton(title: "", icon: UIImage(named: "share_btn")!, backgroundColor: UIColor.whiteColor(),callback: nil)
        shareBtn.buttonWidth = self.view.frame.size.width/3
        
        cell.rightButtons = [shareBtn,readBtn,bookmarkBtn]
        cell.rightSwipeSettings.transition = MGSwipeTransition.Border

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.rowID = indexPath.row
        let cell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        var title = cell.viewWithTag(2)as! UILabel
        title.textColor = UIColor(rgba: "#9B9B9B")
        
        var read = cell.viewWithTag(3) as! UILabel
        read.text = "Read"
        
        var tick = cell.viewWithTag(4) as! UIImageView
        tick.image = UIImage(named: "icon_tick")
        
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
        var font : UIFont = UIFont(name: "OpenSans-Bold", size: 19.5)!
        var constrainedSize: CGSize = CGSizeMake(width, 9999);
        var attributesDictionary = NSDictionary(objectsAndKeys: font, NSFontAttributeName)
        var string = NSMutableAttributedString(string: pString, attributes: attributesDictionary as [NSObject : AnyObject])
        var requiredHeight: CGRect = string.boundingRectWithSize(constrainedSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return requiredHeight.size.height
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ArticleVC" {
            var articleVC : ArticleViewController = segue.destinationViewController as! ArticleViewController
            
//            if Utilities.sharedInstance.getBoolForKey(IS_FROM_CUSTOM_URL) == true {
                articleVC.customURLData = self.customURLData
//            } else {
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
//            }
        }
    }
    
    func onMenuPressed() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    func onPullToRefresh(sender:AnyObject) {
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            isPullToRefresh = true
            if isBookmarked == false && isCategoryFeeds == false {
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
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            var parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        self.refreshCntrl.endRefreshing()
                        
                        CoreDataManager.addBookmarkFeeds(processedData["links"] as! [AnyObject], isSynced: true)
                        self.bookmarks = CoreDataManager.getBookmarkFeeds()
                        
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
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            var parameters : [String:AnyObject] = ["auth_token":auth_token]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(USER_PREFERENCE_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        self.refreshCntrl.endRefreshing()
                        println(processedData["preferences"])
                        var preferencesArray : [AnyObject]? = processedData["preferences"] as? [AnyObject]
                        if preferencesArray != nil && preferencesArray?.count > 0 {
                            
                            var object : AnyObject!
                            for object in preferencesArray! {
                                var preferences : [String:AnyObject] = object as! [String:AnyObject]
                                if preferences["name"]! as! String == DEFAULT_ARTICLE_VIEW {
                                    Utilities.sharedInstance.setStringForKey(preferences["value"]! as! String, key: DEFAULT_ARTICLE_VIEW)
                                } else if preferences["name"]! as! String == DEFAULT_LIST {
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
                    println("Error")
            }
        }
    }
    
    
    func onUpdateYourInterest(){
        self.performSegueWithIdentifier("UpdateInterestsVC", sender: self)
    }
    
    // Notication selectors
    @objc func yourFeedNotificationSelector(notification: NSNotification){
        self.isBookmarked = false
        self.isCategoryFeeds = false
        self.navTitle.text = "Your Feed"
        self.navTitle.frame = CGRectMake(0, 0, 80, 30)
        self.tableView.reloadData()
    }
    
    @objc func bookmarkNotificationSelector(notification: NSNotification){
        self.isCategoryFeeds = false
        self.onBookmark()
    }
    
    @objc func categoryNotificationSelector(notification: NSNotification) {
        
        self.isBookmarked = false
        self.isCategoryFeeds = true
        
        var dict  = notification.userInfo as! Dictionary<String,String>
        self.categoryID = dict["id"]!.toInt()!
        self.categoryName = dict["name"]!
        
        self.downloadCategory(categoryID,categoryName: categoryName)
    }
    
    @objc func settingsNotificationSelector(notification: NSNotification) {
        var settingsVC: SettingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsVC") as! SettingsViewController
        self.navigationController?.showViewController(settingsVC, sender: self)
    }
    
    
    func downloadCategory(categoryID : Int, categoryName:String){
        
        if Utilities.sharedInstance.isConnectedToNetwork() == false && CategoryFeeds.sharedInstance.getCategoryFeeds(categoryID) == nil{
            SVProgressHUD.dismiss()
            self.refreshCntrl.endRefreshing()
            self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
            return
        }
        
        self.categoryFeeds = CategoryFeeds.sharedInstance.getCategoryFeeds(categoryID)
        if  self.categoryFeeds == nil || self.categoryFeeds!.isEmpty || isPullToRefresh == true {
            
            if Utilities.sharedInstance.isConnectedToNetwork() == true {
                if isPullToRefresh == false {
                    SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
                }
                
                isPullToRefresh = false
                
                var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
                var parameters = ["auth_token":auth_token,
                "content":"true"]
                var URL = "\(FEED_URL)/\(categoryID)"
                
                NetworkManager.sharedNetworkClient().processGetRequestWithPath(URL,
                    parameter: parameters,
                    success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                        
                        if requestStatus == 200 {
                            SVProgressHUD.dismiss()
                            self.refreshCntrl.endRefreshing()
                            self.navTitle.text = categoryName
                            
                            CategoryFeeds.sharedInstance.populateFeeds(processedData["links"] as! [AnyObject], categoryID: categoryID)
                            self.categoryFeeds = CategoryFeeds.sharedInstance.getCategoryFeeds(categoryID)
                            self.tableView.reloadData()
                        }
                    }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                        self.menu.enabled = true
                        SVProgressHUD.dismiss()
                        self.refreshCntrl.endRefreshing()
                        
                        if extraInfo != nil {
                            var error : [String:AnyObject] = extraInfo as! Dictionary
                            var message : String = error["error"] as! String
                            
                            if message == "Invalid authentication token." {
                                var alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                    var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                                    self.showViewController(loginVC, sender: self)
                                }))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            
                            self.showAlert("Error !", msg: message)
                        }
                }
            } else {
                SVProgressHUD.dismiss()
                self.refreshCntrl.endRefreshing()
                self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
            }
        } else {
            self.navTitle.text = categoryName
            self.categoryFeeds = CategoryFeeds.sharedInstance.getCategoryFeeds(categoryID)
            self.tableView.reloadData()
        }
    }
    
    func showAlert(title:String, msg:String){
        var alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func onSharePressed(indexPath:Int) {
        var sharingItems = [AnyObject]()
        var url : NSURL!
        if isBookmarked == true {
            
            if isUnreadTab == true {
                sharingItems.append(self.unreadBookmarkFeeds[indexPath].title!)
                sharingItems.append(self.unreadBookmarkFeeds[indexPath].url!)
                url = NSURL(string: unreadBookmarkFeeds[indexPath].url!)
            } else {
                sharingItems.append(self.bookmarks[indexPath].title!)
                sharingItems.append(self.bookmarks[indexPath].url!)
                url = NSURL(string: bookmarks[indexPath].url!)
            }
            
        } else if isCategoryFeeds == true {
            
            if isUnreadTab == true {
                sharingItems.append(self.unreadFeeds[indexPath].title!)
                sharingItems.append(self.unreadFeeds[indexPath].URL!)
                url = NSURL(string: self.unreadFeeds[indexPath].URL!)
            } else {
                sharingItems.append(self.categoryFeeds![indexPath].title!)
                sharingItems.append(self.categoryFeeds![indexPath].URL!)
                url = NSURL(string: self.categoryFeeds![indexPath].URL!)
            }
        } else {
            
            if isUnreadTab == true {
                sharingItems.append(self.unreadFeeds[indexPath].title!)
                sharingItems.append(self.unreadFeeds[indexPath].URL!)
                url = NSURL(string: self.unreadFeeds[indexPath].URL!)
            } else {
                sharingItems.append(feeds[indexPath].title!)
                sharingItems.append(feeds[indexPath].URL!)
                url = NSURL(string: feeds[indexPath].URL!)
            }
        }
        
        sharingItems.append(url)
        
        let activity = ARSafariActivity()
        let activityVC = UIActivityViewController(activityItems:sharingItems, applicationActivities: [activity])
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func onBookmarkPressed(indexPath:NSIndexPath,bookmarkBtn:MGSwipeButton) {
        
        if isBookmarked == true {
            if isUnreadTab == true {
                if self.unreadBookmarkFeeds[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark")!, forState: UIControlState.Normal)
                    self.unreadBookmarkFeeds[indexPath.row].bookmarked = false
                    self.markAsBookmarked(self.unreadBookmarkFeeds[indexPath.row].id!,feed: self.unreadBookmarkFeeds[indexPath.row],indexPath: indexPath)
                    CoreDataManager.removeBookmarkFeedOfID(self.unreadBookmarkFeeds[indexPath.row].id!)
                    self.bookmarks = CoreDataManager.getBookmarkFeeds()
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
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark_filled")!, forState: UIControlState.Normal)
                    self.bookmarks[indexPath.row].bookmarked = true
                    self.markAsBookmarked(self.bookmarks[indexPath.row].id!,feed: self.bookmarks[indexPath.row],indexPath: indexPath)
                }
            } else {
                
                if self.bookmarks[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark")!, forState: UIControlState.Normal)
                    self.bookmarks[indexPath.row].bookmarked = false
                    self.markAsBookmarked(self.bookmarks[indexPath.row].id!,feed: self.bookmarks[indexPath.row],indexPath: indexPath)
                    CoreDataManager.removeBookmarkFeedOfID(self.bookmarks[indexPath.row].id!)
                    self.bookmarks = CoreDataManager.getBookmarkFeeds()
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.tableView.endUpdates()
                } else {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark_filled")!, forState: UIControlState.Normal)
                    self.bookmarks[indexPath.row].bookmarked = true
                    self.markAsBookmarked(self.bookmarks[indexPath.row].id!,feed: self.bookmarks[indexPath.row],indexPath: indexPath)
                }
            }

        } else if isCategoryFeeds == true {
            
            if isUnreadTab == true {
                if self.unreadFeeds[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark")!, forState: UIControlState.Normal)
                    self.unreadFeeds[indexPath.row].bookmarked = false
                } else {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark_filled")!, forState: UIControlState.Normal)
                    self.unreadFeeds[indexPath.row].bookmarked = true
                }
                
                self.markAsBookmarked(self.unreadFeeds[indexPath.row].id!,feed: self.unreadFeeds[indexPath.row],indexPath: indexPath)
            } else {
                if self.categoryFeeds![indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark")!, forState: UIControlState.Normal)
                    self.categoryFeeds![indexPath.row].bookmarked = false
                } else {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark_filled")!, forState: UIControlState.Normal)
                    self.categoryFeeds![indexPath.row].bookmarked = true
                }
                
                self.markAsBookmarked(self.categoryFeeds![indexPath.row].id!,feed: self.categoryFeeds![indexPath.row],indexPath: indexPath)
            }

        } else {
            
            if isUnreadTab == true {
                if self.unreadFeeds[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark")!, forState: UIControlState.Normal)
                    self.unreadFeeds[indexPath.row].bookmarked = false
                } else {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark_filled")!, forState: UIControlState.Normal)
                    self.unreadFeeds[indexPath.row].bookmarked = true
                }
                
                self.markAsBookmarked(self.unreadFeeds[indexPath.row].id!,feed: self.unreadFeeds[indexPath.row],indexPath: indexPath)
            } else {
                if self.feeds[indexPath.row].bookmarked == true {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark")!, forState: UIControlState.Normal)
                    self.feeds[indexPath.row].bookmarked = false
                } else {
                    bookmarkBtn.setImage(UIImage(named: "icon_bookmark_filled")!, forState: UIControlState.Normal)
                    self.feeds[indexPath.row].bookmarked = true
                }
                
                self.markAsBookmarked(self.feeds[indexPath.row].id!,feed: self.feeds[indexPath.row],indexPath: indexPath)
            }
        }
    }
    
    func markAsBookmarked(articleID:Int, feed:AnyObject,indexPath:NSIndexPath){
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            
            var parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "link_id":articleID]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        var message = processedData["message"] as! String
                        var bookmarkDictionary : [String:AnyObject] = processedData["bookmark"] as! Dictionary
                        var linkID = bookmarkDictionary["link_id"] as! Int
                        
                        if message == "Bookmark Created" {
                            
                            if self.isBookmarked == true {
//                                CoreDataManager.addBookmarkFeed(feed as! BookmarkFeed, isSynced: true)
//                                self.bookmarks = CoreDataManager.getBookmarkFeeds()
//                                
//                                var feed : InformerlyFeed
//                                var counter = 0
//                                for feed in self.feeds {
//                                    if feed.id == articleID {
//                                        self.feeds[counter].bookmarked = true
//                                        break
//                                    }
//                                    counter++
//                                }
                                
                            } else {
                                CoreDataManager.addBookmarkFeed(feed as! InformerlyFeed, isSynced: true)
                                self.bookmarks = CoreDataManager.getBookmarkFeeds()
                            }
                        } else if message == "Bookmark Removed" {
                            if self.isBookmarked == true {
                                self.bookmarks = CoreDataManager.getBookmarkFeeds()
                                
                                var feed : InformerlyFeed
                                var counter = 0
                                for feed in self.feeds {
                                    if feed.id == articleID {
                                        self.feeds[counter].bookmarked = false
                                        break
                                    }
                                    counter++
                                }
                            } else {
                                CoreDataManager.removeBookmarkFeedOfID(articleID)
                            }
                        }
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    
                    if extraInfo != nil {
                        var error : [String:AnyObject] = extraInfo as! Dictionary
                        var message : String = error["error"] as! String
                        self.showAlert("Error !", msg: message)
                    }
            }
        } else {
            // Offline mode
            
            if isBookmarked == false {
                var tempFeed : InformerlyFeed = feed as! InformerlyFeed
                if tempFeed.bookmarked == false {
                    CoreDataManager.removeBookmarkFeedOfID(tempFeed.id!)
                } else {
                    CoreDataManager.addBookmarkFeed(feed as! InformerlyFeed, isSynced: false)
                }
                self.bookmarks = CoreDataManager.getBookmarkFeeds()
            } else {
                CoreDataManager.removeBookmarkFeedOfID(indexPath.row)
                self.bookmarks = CoreDataManager.getBookmarkFeeds()
            }
        }
    }
    
    func onMarkReadPressed(indexPath:NSIndexPath,readBtn:MGSwipeButton) {
        
        let cell : MGSwipeTableCell = self.tableView.cellForRowAtIndexPath(indexPath) as! MGSwipeTableCell
//        cell.rightSwipeSettings.animationDuration = 2
        var title = cell.viewWithTag(2) as! UILabel
        var readingTime = cell.viewWithTag(3) as! UILabel
        var tick = cell.viewWithTag(4) as! UIImageView
        
        if isBookmarked == true {
            if isUnreadTab == true {
                readBtn.setImage(UIImage(named: "icon_check_circle"), forState: UIControlState.Normal)
                markAsRead(indexPath)
                
                var counter = 0
                for feed in self.bookmarks {
                    if feed.id == unreadBookmarkFeeds[indexPath.row].id {
                        self.bookmarks[counter].read = true
                    }
                    counter++
                }
                
                unreadBookmarkFeeds.removeAtIndex(indexPath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.endUpdates()
                
            } else {
                if self.bookmarks[indexPath.row].read == true {
                    readBtn.setImage(UIImage(named: "icon_tick"), forState: UIControlState.Normal)
                    markAsUnread(indexPath)
                    
                    title.textColor = UIColor.blackColor()
                    readingTime.text = "\(String(self.bookmarks[indexPath.row].readingTime!)) min read"
                    tick.image = UIImage(named: "clock_icon")
                    
                } else {
                    readBtn.setImage(UIImage(named: "icon_check_circle"), forState: UIControlState.Normal)
                    markAsRead(indexPath)
                    
                    readingTime.text = "Read"
                    tick.image = UIImage(named: "icon_tick")
                }
            }
            
        } else if isCategoryFeeds == true {
            
            if isUnreadTab == true {
                readBtn.setImage(UIImage(named: "icon_check_circle"), forState: UIControlState.Normal)
                markAsRead(indexPath)
                
                var counter = 0
                for feed in self.categoryFeeds! {
                    if feed.id == unreadFeeds[indexPath.row].id {
                        self.categoryFeeds![counter].read = true
                    }
                    counter++
                }
                
                unreadFeeds.removeAtIndex(indexPath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.endUpdates()
            
            } else {
                if self.categoryFeeds![indexPath.row].read == true {
                    readBtn.setImage(UIImage(named: "icon_tick"), forState: UIControlState.Normal)
                    markAsUnread(indexPath)
                    
                    title.textColor = UIColor.blackColor()
                    readingTime.text = "\(String(self.categoryFeeds![indexPath.row].readingTime!)) min read"
                    tick.image = UIImage(named: "clock_icon")
                    
                } else {
                    readBtn.setImage(UIImage(named: "icon_check_circle"), forState: UIControlState.Normal)
                    markAsRead(indexPath)
                    
                    title.textColor = UIColor(rgba: "#9B9B9B")
                    readingTime.text = "Read"
                    tick.image = UIImage(named: "icon_tick")
                }
            }
            
        } else {
            
            if isUnreadTab == true {
                readBtn.setImage(UIImage(named: "icon_check_circle"), forState: UIControlState.Normal)
                markAsRead(indexPath)
                
                var counter = 0
                for feed in self.feeds {
                    if feed.id == unreadFeeds[indexPath.row].id {
                        self.feeds[counter].read = true
                    }
                    counter++
                }
                
                self.unreadFeeds.removeAtIndex(indexPath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.endUpdates()
            } else {
                if self.feeds[indexPath.row].read == true {
                    readBtn.setImage(UIImage(named: "icon_tick"), forState: UIControlState.Normal)
                    markAsUnread(indexPath)
                    
                    title.textColor = UIColor.blackColor()
                    readingTime.text = "\(String(self.feeds[indexPath.row].readingTime!)) min read"
                    tick.image = UIImage(named: "clock_icon")
                    
                } else {
                    readBtn.setImage(UIImage(named: "icon_check_circle"), forState: UIControlState.Normal)
                    markAsRead(indexPath)
                    
                    title.textColor = UIColor(rgba: "#9B9B9B")
                    readingTime.text = "Read"
                    tick.image = UIImage(named: "icon_tick")
                    
                }
            }
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
        
        var parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
            "client_id":"",
            "link_id": articleID]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                println("Successfully marked as read.")
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                println("Failure marking article as read")
                
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
                    var message : String = error["error"] as! String
                    
                    if message == "Invalid authentication token." {
                        var alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
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
        
        var parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
            "link_id": articleID]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                println("Successfully marked as unread.")
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                println("Failure marking article as unread")
                
                if extraInfo != nil {
                    var error : [String:AnyObject] = extraInfo as! Dictionary
                    var message : String = error["error"] as! String
                    
                    if message == "Invalid authentication token." {
                        var alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                            self.showViewController(loginVC, sender: self)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
        }
        
    }
    
    // Swipe Cell delegates
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        var indexPath : NSIndexPath = self.tableView.indexPathForCell(cell)!
        if index == 0 {
            self.onSharePressed(indexPath.row)
            return true
        } else if index == 1 {
            var btn = cell.rightButtons[1] as! MGSwipeButton
            self.onMarkReadPressed(indexPath, readBtn: btn)
            return true
        } else {
            var btn = cell.rightButtons[2] as! MGSwipeButton
            self.onBookmarkPressed(indexPath,bookmarkBtn: btn)
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}