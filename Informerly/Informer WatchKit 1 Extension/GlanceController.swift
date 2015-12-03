//
//  GlanceController.swift
//  Informer WatchKit Extension
//
//  Created by Apple on 30/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    var feeds : [AnyObject]!
    
    @IBOutlet var lblSource: WKInterfaceLabel!
    @IBOutlet var lblTitle: WKInterfaceLabel!
    @IBOutlet var lblDescription: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Configure interface objects here.
        if Utilities.sharedInstance.getBoolForAppGroupKey(IS_USER_LOGGED_IN) == false {
            if self.feeds != nil {
                self.feeds.removeAll(keepCapacity: false)
            }
            self.lblTitle.setText("")
            self.lblSource.setText("")
            self.lblDescription.setText("Please Login on your phone to proceed.")
        } else {
            self.lblSource.setText("Loading ...")
            self.lblTitle.setText("")
            self.lblDescription.setText("")
            downloadData()
        }

    }
    
    func downloadData() {
        WKInterfaceController.openParentApplication(["action":"getFeeds"], reply: { (replyInfo, error) -> Void in
            self.feeds = replyInfo["result"] as! [AnyObject]
            self.populateView()
        })
    }
    
    func populateView() {
        let index = arc4random_uniform(UInt32(self.feeds.count))
        
        var feed = self.feeds[Int(index)] as! [String:AnyObject]
        self.lblSource.setText(feed["source"] as? String)
        self.lblSource.setTextColor(UIColor(rgba: feed["source_color"] as! String))
        self.lblTitle.setText(feed["title"] as? String)
        self.lblDescription.setText(feed["description"] as? String)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
