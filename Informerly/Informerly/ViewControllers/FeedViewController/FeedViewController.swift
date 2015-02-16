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
    private var rowID : Int!
    private var indicator : UIActivityIndicatorView!
    private var width : CGFloat!
    var refreshCntrl : UIRefreshControl!
    
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
        
        // Getting screen width.
        width = UIScreen.mainScreen().bounds.width - 40
        
        // Pull to Refresh
        self.refreshCntrl = UIRefreshControl()
        self.refreshCntrl.addTarget(self, action: Selector("onPullToRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshCntrl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = false
        
        if Utilities.sharedInstance.getBoolForKey(FROM_MENU_VC) == false {
            
            // Setting up activity indicator
            indicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2 - 25,self.view.frame.height/2 - 100, 50, 50)) as UIActivityIndicatorView
            indicator.hidesWhenStopped = true
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(indicator)
            self.indicator.startAnimating()
            
            // Download feeds.
            self.downloadData()
        } else {
            Utilities.sharedInstance.setBoolForKey(false, key: FROM_MENU_VC)
        }
    }
    
    func createNavTitle() {
        var title : UILabel = UILabel(frame: CGRectMake(0, 0, 65, 30))
        title.text = "Your Feed"
        title.font = UIFont(name: "OpenSans-Reguler", size: 14.0)
        self.navigationItem.titleView = title
    }
    
    func downloadData() {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var auth_token = Utilities.sharedInstance.getStringForKey(AUTH_TOKEN)
            var parameters = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath(FEED_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        self.indicator.stopAnimating()
                        self.refreshCntrl.endRefreshing()
                        Feeds.sharedInstance.populateFeeds(processedData["links"] as [AnyObject])
                        self.feedsData.removeAll(keepCapacity: false)
                        self.feedsData = Feeds.sharedInstance.getFeeds()
                        
                        var link_id : String! = Utilities.sharedInstance.getStringForKey(LINK_ID)
                        println(link_id)
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
                        var indexPath : NSIndexPath = NSIndexPath(forRow: row, inSection: 0)
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    self.indicator.stopAnimating()
                    self.refreshCntrl.endRefreshing()
                    println(error)
                    var error : [String:AnyObject] = extraInfo as Dictionary
                    var message : String = error["error"] as String
                    
                    self.showAlert("Error !", msg: message)
            }
        } else {
            indicator.stopAnimating()
            self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
        }
    }
    
    // TableView delegates and Data source methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedsData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  self.getTextHeight(feedsData[indexPath.row].title!, width: width) + CGFloat(68)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var source = cell.viewWithTag(1) as UILabel
        var title = cell.viewWithTag(2) as UILabel
        var readingTime = cell.viewWithTag(3) as UILabel
        var tick = cell.viewWithTag(4) as UIImageView
        
        source.text = feedsData[indexPath.row].source
        source.textColor = UIColor(rgba: feedsData[indexPath.row].sourceColor!)
        
        title.text = feedsData[indexPath.row].title
        
        if feedsData[indexPath.row].read != true {
            title.textColor = UIColor.blackColor()
            readingTime.text = "\(String(feedsData[indexPath.row].readingTime!)) min read"
            tick.image = UIImage(named: "clock_icon")
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
        
        var title = cell.viewWithTag(2) as UILabel
        title.textColor = UIColor(rgba: "#9B9B9B")
        
        var read = cell.viewWithTag(3) as UILabel
        read.text = "Read"
        
        var tick = cell.viewWithTag(4) as UIImageView
        tick.image = UIImage(named: "icon_tick")
        
        self.performSegueWithIdentifier("ArticleVC", sender: self)
    }
    
    func getTextHeight(pString: String, width: CGFloat) -> CGFloat {
        var fontSize: CGFloat = 18;
        var font : UIFont = UIFont(name: "OpenSans-Bold", size: 18)!
        var constrainedSize: CGSize = CGSizeMake(width, 9999);
        var attributesDictionary = NSDictionary(objectsAndKeys: font, NSFontAttributeName)
        var string = NSMutableAttributedString(string: pString, attributes: attributesDictionary)
        var requiredHeight: CGRect = string.boundingRectWithSize(constrainedSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return requiredHeight.size.height
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ArticleVC" {
            var articleVC : ArticleViewController = segue.destinationViewController as ArticleViewController
            articleVC.articleIndex = rowID
        }
    }
    
    func onMenuPressed() {
        var menuVC = self.storyboard?.instantiateViewControllerWithIdentifier("menuVC") as UIViewController
        self.presentViewController(menuVC, animated: true, completion: nil)
    }
    
    func onPullToRefresh(sender:AnyObject) {
        self.downloadData()
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