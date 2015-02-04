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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Your Feed"
        self.downloadData()
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
                    Feeds.sharedInstance.populateFeeds(processedData["links"] as [AnyObject])
                    self.feedsData = Feeds.sharedInstance.getFeeds()
                    self.tableView.reloadData()
                }
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var source = cell.viewWithTag(1) as UILabel
        var title = cell.viewWithTag(2) as UILabel
        var readingTime = cell.viewWithTag(3) as UILabel
        
        source.text = feedsData[indexPath.row].source
        title.text = feedsData[indexPath.row].title
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