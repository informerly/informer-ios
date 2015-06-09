//
//  FeedViewController.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class FeedViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    private var cellHeight : CGFloat!
    
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
        
        //TableView header
        self.createTableViewHeader()
        
        // Pull to Refresh
        self.refreshCntrl = UIRefreshControl()
        self.refreshCntrl.addTarget(self, action: Selector("onPullToRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshCntrl)
        
        self.downloadData()
        self.downloadBookmark()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBar.hidden = false
        
        self.bookmarks = CoreDataManager.getBookmarkFeeds()
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
        
        var customSegmentedControl = UISegmentedControl (items: ["All News","Unread"])
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
        self.cellHeight = self.getTextHeight(feeds[indexPath.row].title!, width: width) + CGFloat(68)
        return self.getTextHeight(feeds[indexPath.row].title!, width: width) + CGFloat(68)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : MGSwipeTableCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! MGSwipeTableCell
        
        cell.rightButtons = [self.createCellSwipeView()]
        cell.rightSwipeSettings.transition = MGSwipeTransition.Border
        
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
                    readingTime.text = "\(feed.readingTime) min read"
                    tick.image = UIImage(named: "clock_icon")
                }
            } else {
//                title.textColor = UIColor(rgba: "#9B9B9B")
                readingTime.text = "Read"
                tick.image = UIImage(named: "icon_tick")
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
                    readingTime.text = "\(feed.readingTime) min read"
                    tick.image = UIImage(named: "clock_icon")
                }
            } else {
//                title.textColor = UIColor(rgba: "#9B9B9B")
                readingTime.text = "Read"
                tick.image = UIImage(named: "icon_tick")
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
            }
        }
        
        
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
        
        self.performSegueWithIdentifier("ArticleVC", sender: self)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "yourFeedNotificationSelector:", name:"YourFeedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bookmarkNotificationSelector:", name:"BookmarkNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "categoryNotificationSelector:", name:"CategoryNotification", object: nil)
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
    
    func downloadBookmark(){
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
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in

            }
        }

    }
    
    func onBookmark(){
        
        if isPullToRefresh == true {
            self.downloadBookmark()
            isPullToRefresh = false
        }
        
        self.isBookmarked = true
        self.createNavTitle()
        self.bookmarks = CoreDataManager.getBookmarkFeeds()
        self.tableView.reloadData()
        
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
    
    func createCellSwipeView() -> UIView {
        var swipeView : UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.cellHeight))
        swipeView.backgroundColor = UIColor.greenColor()
        
        let bookmarkBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        bookmarkBtn.frame = CGRectMake(100 - 25, swipeView.frame.size.height/2 - 25, 50, 50)
        bookmarkBtn.backgroundColor = UIColor.redColor()
        var bookmarkImage : UIImage = UIImage(named: "icon_bookmark")!
        bookmarkImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        bookmarkBtn.setImage(bookmarkImage, forState: UIControlState.Normal)
//        bookmarkBtn.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        swipeView.addSubview(bookmarkBtn)
        
        let shareBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        shareBtn.frame = CGRectMake(swipeView.frame.size.width - 100 - 25, swipeView.frame.size.height/2 - 25, 50, 50)
        shareBtn.backgroundColor = UIColor.redColor()
        var shareImage : UIImage = UIImage(named: "share_btn")!
        shareImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        shareBtn.setImage(shareImage, forState: UIControlState.Normal)
//        shareBtn.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        swipeView.addSubview(shareBtn)
        
        return swipeView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}