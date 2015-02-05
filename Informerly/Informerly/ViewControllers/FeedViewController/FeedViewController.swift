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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.hidden = false
        self.createNavTitle()
        actInd = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
        self.actInd.startAnimating()
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
                
                self.actInd.stopAnimating()
                if requestStatus == 200 {
                    Feeds.sharedInstance.populateFeeds(processedData["links"] as [AnyObject])
                    self.feedsData = Feeds.sharedInstance.getFeeds()
                    self.tableView.reloadData()
                }
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                self.actInd.stopAnimating()
                println("Error : " + error.localizedDescription)
                
//                var error : [String:AnyObject] = extraInfo as Dictionary
//                var message : String = error["message"] as String
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
        
        var title = UILabel(frame: CGRectMake(20, 40, 280, 9999))
        title.numberOfLines = 0
        title.tag = 2
        title.lineBreakMode = NSLineBreakMode.ByWordWrapping
        title.font = UIFont(name: "Open Sans-Bold", size: 18.0)
        title.text = feedsData[indexPath.row].title
        title.sizeToFit()
        
        return title.frame.height + CGFloat(81)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var source = cell.viewWithTag(1) as UILabel
        source.text = feedsData[indexPath.row].source
        
        var title:UILabel!
        if (cell.viewWithTag(2) == nil) {
            title = UILabel(frame: CGRectMake(20, 40, 280, 9999))
            title.numberOfLines = 0
            title.tag = 2
            title.lineBreakMode = NSLineBreakMode.ByWordWrapping
            title.font = UIFont(name: "Open Sans-Bold", size: 18.0)
            title.text = feedsData[indexPath.row].title
            title.sizeToFit()
            cell.addSubview(title)
        } else {
            title = cell.viewWithTag(2) as UILabel
            title.text = feedsData[indexPath.row].title
        }
        
        var readingTime = cell.viewWithTag(3) as UILabel
        readingTime.text = "\(String(feedsData[indexPath.row].readingTime!)) min read"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.rowID = indexPath.row
        self.performSegueWithIdentifier("ArticleVC", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ArticleVC" {
            var articleVC : ArticleViewController = segue.destinationViewController as ArticleViewController
            articleVC.articleData = feedsData[rowID]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}