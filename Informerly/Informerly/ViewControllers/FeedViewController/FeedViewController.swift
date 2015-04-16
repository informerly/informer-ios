//
//  FeedViewController.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class FeedViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var feedsData : [Feeds.InformerlyFeed] = []
    private var unreadFeeds : [Feeds.InformerlyFeed] = []
    private var bookmarkedFeeds : [Feeds.InformerlyFeed] = []
    private var rowID : Int!
    private var indicator : UIActivityIndicatorView!
    private var width : CGFloat!
    var refreshCntrl : UIRefreshControl!
    private var isUnreadTab = false
    private var isBookmarked = false
    private var menu:REMenu!
    private var navTitle : UILabel!
    private var arrow : UIButton!
    private var overlay:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Nav bar.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.hidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.createNavTitle()
        
        // Adds menu icon on nav bar.
        var menu : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onMenuPressed"))
        menu.tintColor = UIColor.grayColor()
        self.navigationItem.leftBarButtonItem = menu
        
        // Create Top menu
        self.createTopMenu()
        
        // Getting screen width.
        width = UIScreen.mainScreen().bounds.width - 40
        
        
        //TableView header
        self.createTableViewHeader()
        
        // Pull to Refresh
        self.refreshCntrl = UIRefreshControl()
        self.refreshCntrl.addTarget(self, action: Selector("onPullToRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshCntrl)
        
        // Setting up activity indicator
        indicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2 - 50, 0, 0)) as UIActivityIndicatorView
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(indicator)
        
        self.createOverlayView()
        self.downloadData()
        self.downloadBookmark()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBar.hidden = false
    }
    
    func createTopMenu(){
        var yourFeed : REMenuItem = REMenuItem(title: "Your Feed", image: UIImage(named: "icon_home"), backgroundColor: UIColor.whiteColor(), highlightedImage: nil) { (item) -> Void in
            self.downloadData()
            self.menu.close()
        }
        
//        var item2 : REMenuItem = REMenuItem(title: "Category1", image: UIImage(named: "icon_folder"), backgroundColor: UIColor.whiteColor(), highlightedImage: nil) { (item) -> Void in
//            self.menu.close()
//        }
//        var item3 : REMenuItem = REMenuItem(title: "Category2", image: UIImage(named: "icon_folder"), backgroundColor: UIColor.whiteColor(), highlightedImage: nil) { (item) -> Void in
//            self.menu.close()
//        }
//        var item4 : REMenuItem = REMenuItem(title: "Category3", image: UIImage(named: "icon_folder"), backgroundColor: UIColor.whiteColor(), highlightedImage: nil) { (item) -> Void in
//            self.menu.close()
//        }
        var bookmarkFeeds : REMenuItem = REMenuItem(title: "Bookmarks", image: UIImage(named: "icon_bookmark"), backgroundColor: UIColor.whiteColor(), highlightedImage: nil) { (item) -> Void in
            self.indicator.startAnimating()
            self.onBookmark()
        }
        
        menu = REMenu(items: [yourFeed,bookmarkFeeds])
        menu.backgroundColor = UIColor.whiteColor()
        menu.separatorHeight = 1
        menu.separatorColor = UIColor(rgba: "#E6E7E8")
        menu.textAlignment = NSTextAlignment.Left
        menu.textOffset = CGSizeMake(50, 0)
        menu.textColor = UIColor(rgba: "#4A4A4A")
        menu.font = UIFont(name: "Open Sans", size: 15)
        menu.borderColor = UIColor(rgba: "#E6E7E8")
        menu.highlightedBackgroundColor = UIColor(rgba: "#E6E7E8")
        menu.highlightedSeparatorColor = UIColor(rgba: "#E6E7E8")

    }
    
    func createNavTitle() {
        
        if isBookmarked == false {
            var navTitleView : UIView = UIView(frame: CGRectMake(0, 0, 90, 30))
            
            navTitle = UILabel(frame: CGRectMake(0, 0, 80, 30))
            navTitle.text = "Your Feed"
            navTitle.font = UIFont(name: "OpenSans-Regular", size: 14.0)
            
            arrow = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            arrow.setImage(UIImage(named: "icon_arrow"), forState: UIControlState.Normal)
            arrow.frame = CGRectMake(81, 13, 10, 5)
            arrow.tintColor = UIColor.grayColor()
            
            navTitleView.addSubview(navTitle)
            navTitleView.addSubview(arrow)
            
            var titleViewTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onNavBarTitleTap:"))
            navTitleView.addGestureRecognizer(titleViewTap)
            
            self.navigationItem.titleView = navTitleView
        } else {
            navTitle.frame = CGRectMake(0, 0, 100, 30)
            navTitle.text = "Bookmarked"
            arrow.frame = CGRectMake(101, 13, 10, 5)
        }
    }
    
    func createOverlayView(){
        
        // Calculating origin for webview
        var statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        var navBarHeight = self.navigationController?.navigationBar.frame.height
        var resultantHeight = statusBarHeight + navBarHeight!
        
        self.overlay = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight))
        self.overlay.backgroundColor = UIColor.clearColor()
        self.overlay.hidden = true
        self.view.addSubview(self.overlay)
    }
    
    func onNavBarTitleTap(gesture : UIGestureRecognizer) {
        
        if (self.menu.isOpen) {
            self.menu.close()
        } else {
            menu.showFromNavigationController(self.navigationController)
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
        
        self.indicator.startAnimating()
        self.overlay.hidden = false
        
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
                        self.overlay.hidden = true
                        self.indicator.stopAnimating()
                        self.refreshCntrl.endRefreshing()
                        Feeds.sharedInstance.populateFeeds(processedData["links"]as! [AnyObject])
                        self.feedsData.removeAll(keepCapacity: false)
                        self.unreadFeeds.removeAll(keepCapacity: false)
                        self.bookmarkedFeeds.removeAll(keepCapacity: false)
                        
                        self.isBookmarked = false
                        self.navTitle.text = "Your Feed"
                        self.navTitle.frame = CGRectMake(0, 0, 80, 30)
                        self.arrow.frame = CGRectMake(81, 13, 10, 5)
                        
                        self.feedsData = Feeds.sharedInstance.getFeeds()
                        
                        var link_id : String! = Utilities.sharedInstance.getStringForKey(LINK_ID)
                        var row = -1
                        if link_id != "-1" {
                            var feed : Feeds.InformerlyFeed!
                            if  link_id != nil {
                                for feed in self.feedsData {
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
                            Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
                            self.rowID = row
                            self.performSegueWithIdentifier("ArticleVC", sender: self)
                        }
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    self.overlay.hidden = true
                    self.indicator.stopAnimating()
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
                        self.showAlert("Error !", msg: "Try Again!")
                    }
            }
        } else {
            indicator.stopAnimating()
            self.refreshCntrl.endRefreshing()
            self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
        }
    }
    
    // TableView delegates and Data source methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isUnreadTab == true && isBookmarked == false {
            unreadFeeds = []
            for feed in self.feedsData {
                if feed.read == false {
                    unreadFeeds.append(feed)
                }
            }
            return unreadFeeds.count
        }
        else if isUnreadTab == true && isBookmarked == true {
            unreadFeeds = []
            for feed in self.bookmarkedFeeds {
                if feed.read == false {
                    unreadFeeds.append(feed)
                }
            }
            return unreadFeeds.count
        }
        else if isBookmarked == true {
            return bookmarkedFeeds.count
        }
        return feedsData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if isUnreadTab == true {
            return self.getTextHeight(unreadFeeds[indexPath.row].title!, width: width) + CGFloat(68)
        } else if isBookmarked == true {
            return self.getTextHeight(bookmarkedFeeds[indexPath.row].title!, width: width) + CGFloat(68)
        }
        return self.getTextHeight(feedsData[indexPath.row].title!, width: width) + CGFloat(68)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")as! UITableViewCell
        
        var source = cell.viewWithTag(1) as! UILabel
        var title = cell.viewWithTag(2) as! UILabel
        var readingTime = cell.viewWithTag(3) as! UILabel
        var tick = cell.viewWithTag(4) as! UIImageView
        
        var feed : Feeds.InformerlyFeed;
        if isUnreadTab == true {
            feed = unreadFeeds[indexPath.row]
        } else if isBookmarked == true {
            feed = bookmarkedFeeds[indexPath.row]
        } else {
            feed = feedsData[indexPath.row]
        }
        
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
        var fontSize: CGFloat = 18;
        var font : UIFont = UIFont(name: "OpenSans-Bold", size: 18)!
        var constrainedSize: CGSize = CGSizeMake(width, 9999);
        var attributesDictionary = NSDictionary(objectsAndKeys: font, NSFontAttributeName)
        var string = NSMutableAttributedString(string: pString, attributes: attributesDictionary as [NSObject : AnyObject])
        var requiredHeight: CGRect = string.boundingRectWithSize(constrainedSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return requiredHeight.size.height
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ArticleVC" {
            var articleVC : ArticleViewController = segue.destinationViewController as! ArticleViewController
            articleVC.articleIndex = rowID
            articleVC.isUnreadTab = self.isUnreadTab
            articleVC.isBookmarked = self.isBookmarked
            if isUnreadTab == true {
                articleVC.unreadFeeds = self.unreadFeeds
            }
        }
    }
    
    func onMenuPressed() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    func onPullToRefresh(sender:AnyObject) {
        
        if isBookmarked == false {
            self.downloadData()
        } else {
            self.onBookmark()
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
                        
                        Utilities.sharedInstance.setArrayForKey(NSKeyedArchiver.archivedDataWithRootObject(processedData) , key: BOOKMARK_FEEDS)
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in

            }
        }

    }
    
    func onBookmark(){
        self.overlay.hidden = false
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            println(auth_token)
            var parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        println(processedData)
                        self.refreshCntrl.endRefreshing()
                        self.overlay.hidden = true
                        self.indicator.stopAnimating()
                        self.isBookmarked = true
                        self.createNavTitle()
                        Feeds.sharedInstance.populateFeeds(processedData["links"] as! [AnyObject])
                        self.bookmarkedFeeds = Feeds.sharedInstance.getFeeds()
                        
                        self.tableView.reloadData()
                        self.menu.close()
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    
                    if extraInfo != nil {
                        self.refreshCntrl.endRefreshing()
                        self.overlay.hidden = true
                        self.indicator.stopAnimating()
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
                        self.showAlert("Error !", msg: "Try Again!")
                    }
            }
        } else {
            self.refreshCntrl.endRefreshing()
            self.overlay.hidden = true
            self.indicator.stopAnimating()
            self.isBookmarked = true
            self.createNavTitle()
            
            var processedData : AnyObject = Utilities.sharedInstance.getArrayForKey(BOOKMARK_FEEDS)
            Feeds.sharedInstance.populateFeeds(processedData["links"] as! [AnyObject])
            self.bookmarkedFeeds = Feeds.sharedInstance.getFeeds()
            self.tableView.reloadData()
            self.menu.close()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showAlert(title:String, msg:String){
        var alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}