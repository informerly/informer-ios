//
//  FirstInterfaceController.swift
//  Informerly
//
//  Created by Apple on 16/09/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import WatchKit
import Foundation

class FirstInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var sourceLabel: WKInterfaceLabel!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var separator: WKInterfaceSeparator!
    
    var feeds : [AnyObject]?
    static var isFirst : Bool = true
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if (context != nil) {
            loadData(context!)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        if(FirstInterfaceController.isFirst) {
            if Utilities.sharedInstance.getBoolForAppGroupKey(IS_USER_LOGGED_IN) == true {
                if self.feeds != nil {
                    self.feeds!.removeAll(keepCapacity: false)
                } else {
                    self.sourceLabel.setText("")
                    self.titleLabel.setText("")
                    self.separator.setHidden(true)
                    self.descriptionLabel.setText("Loading ...")
                    downloadData()
                }
            }
            FirstInterfaceController.isFirst = false;
        }
        
    }
    
    func downloadData() {
        WKInterfaceController.openParentApplication(["action":"getFeeds"], reply: { (replyInfo, error) -> Void in
            
//            if (replyInfo != nil) {
                self.feeds = replyInfo["result"] as? [AnyObject]
                let interfaceNames = ["FirstController","SecondController","ThirdController","FourthController","FifthController",
                    "SixthController","SeventhController","EightController","NinthController","TenthController"]
                
                let data = [self.feeds![0],self.feeds![1],self.feeds![2],self.feeds![3],self.feeds![4],self.feeds![5],self.feeds![6],self.feeds![7],self.feeds![8],self.feeds![9]]
                
                WKInterfaceController.reloadRootControllersWithNames(interfaceNames, contexts: data)
                
//            } else {
//                self.sourceLabel.setText("")
//                self.titleLabel.setText("")
//                self.separator.setHidden(true)
//                self.descriptionLabel.setText("Unable to load data. Please try again ...")
//            }
        })
    }
    
    func loadData(data:AnyObject){
        var feed : [String:AnyObject] = data as! [String : AnyObject]
        self.sourceLabel.setText(feed["source"] as? String)
        self.sourceLabel.setTextColor(UIColor(rgba: feed["source_color"] as! String))
        self.titleLabel.setText(feed["title"] as? String)
        self.separator.setHidden(false)
        self.descriptionLabel.setText(feed["description"] as? String)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
