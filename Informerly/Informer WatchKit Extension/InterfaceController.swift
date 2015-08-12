//
//  InterfaceController.swift
//  Informer WatchKit Extension
//
//  Created by Apple on 30/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var feedsTable: WKInterfaceTable!
    var interfaceImage : WKInterfaceImage!
    var feeds : [AnyObject]!
    @IBOutlet weak var loadingLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    func downloadData() {
        
        WKInterfaceController.openParentApplication(["action":"getFeeds"], reply: { (replyInfo, error) -> Void in
            self.feeds = replyInfo["result"] as! [AnyObject]
            self.loadingLabel.setHidden(true)
            self.loadFeeds()
        })
    }
    
    func loadFeeds(){
        feedsTable.setNumberOfRows(self.feeds.count, withRowType: "FeedRow")
        for (index,feed) in enumerate(self.feeds) {
            let row = feedsTable.rowControllerAtIndex(index) as? FeedRowController
            row?.feedTitle.setText(feed["title"] as? String)
            row?.feedSource.setText(feed["source"] as? String)
            row?.feedSource.setTextColor(UIColor(rgba: feed["source_color"] as! String))
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        self.pushControllerWithName("showArticle", context: self.feeds[rowIndex]["description"])
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Configure interface objects here.
        if Utilities.sharedInstance.getBoolForAppGroupKey(IS_USER_LOGGED_IN) == false {
            if self.feeds != nil {
                self.feeds.removeAll(keepCapacity: false)
                self.loadFeeds()
            }
            self.loadingLabel.setHidden(false)
            self.loadingLabel.setText("Please Login on your phone to proceed.")
        } else {
            self.loadingLabel.setText("Loading ...")
            downloadData()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
