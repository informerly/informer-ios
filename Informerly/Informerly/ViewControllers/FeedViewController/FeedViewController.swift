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
    private var actInd : UIActivityIndicatorView!
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
        width = UIScreen.mainScreen().bounds.width - 35
        
        // Pull to Refresh
        self.refreshCntrl = UIRefreshControl()
        self.refreshCntrl.addTarget(self, action: Selector("onPullToRefresh:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshCntrl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Setting up activity indicator
        actInd = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
        self.actInd.startAnimating()
        
        // Download feeds.
        self.downloadData()
    }
    
    func createNavTitle() {
        var title : UILabel = UILabel(frame: CGRectMake(0, 0, 65, 30))
        title.text = "Your Feed"
        title.font = UIFont(name: "Open Sans", size: 14.0)
        self.navigationItem.titleView = title
    }
    
    func downloadData() {
        
        var auth_token = Utilities.sharedInstance.getStringForKey(AUTH_TOKEN)
        var parameters = ["auth_token":auth_token,
                          "client_id":"dev-ios-informer",
                          "content":"true"]
        
        NetworkManager.sharedNetworkClient().processGetRequestWithPath(FEED_URL,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                
                if requestStatus == 200 {
                    self.actInd.stopAnimating()
                    self.refreshCntrl.endRefreshing()
                    Feeds.sharedInstance.populateFeeds(processedData["links"] as [AnyObject])
                    self.feedsData.removeAll(keepCapacity: false)
                    self.feedsData = Feeds.sharedInstance.getFeeds()
                    self.tableView.reloadData()
                }
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                self.actInd.stopAnimating()
                self.refreshCntrl.endRefreshing()
                
//                var error : [String:AnyObject] = extraInfo as Dictionary
//                var message : String = extraInfo as String
//                
//                var alert = UIAlertController(title: "Error!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//                self.presentViewController(alert, animated: true, completion: nil)
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
}