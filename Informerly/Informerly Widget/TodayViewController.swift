//
//  TodayViewController.swift
//  Informerly Widget
//
//  Created by Apple on 20/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextStoryBtn: UIButton!
    var feeds : [AnyObject]!
    var index : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        index = 0
        self.nextStoryBtn.layer.borderColor = UIColor(rgba: "#64ACFF").CGColor
        self.nextStoryBtn.layer.borderWidth = 2.0
        self.nextStoryBtn.layer.cornerRadius = 5.0
        
        
        //Article Web View Gestures
        var tap = UITapGestureRecognizer(target: self, action: "onTitleTap")
        self.titleLabel.addGestureRecognizer(tap)
        titleLabel.userInteractionEnabled = true
        
        var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.Informerly.informerWidget")!
        var token : String! = userDefaults.stringForKey("auth_token")
        
        if token != nil && token != "" {
            var parameters = ["auth_token":token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath("feeds",
                parameter: parameters,
                success: { (requestStatus : Int32, processedData : AnyObject!, extraInfo : AnyObject!) -> Void in
                    if requestStatus == 200 {
                        self.feeds = processedData["links"] as Array
                        var feed : [String:AnyObject] = self.feeds[self.index] as Dictionary
                        var title : String = feed["title"] as String
                        println(title)
                        self.titleLabel.text = title
                        self.nextStoryBtn.hidden = false
                    }
                }) { (status : Int32, error : NSError!, extraInfo:AnyObject!) -> Void in
                    println("error")
            }
        } else {
            self.titleLabel.text = "Unable to load title."
            self.nextStoryBtn.hidden = true
        }
    }
    
    func onTitleTap() {
        
        var feed : [String:AnyObject] = self.feeds[self.index] as Dictionary
        var id : Int = feed["id"] as Int
        
        var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.Informerly.informerWidget")!
        userDefaults.setObject("\(id)", forKey: "id")
        userDefaults.synchronize()
        
        var url =  NSURL(string:"TodayExtension://home")
        self.extensionContext?.openURL(url!, completionHandler:{(success: Bool) -> Void in
            println("task done!")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var newMargins : UIEdgeInsets = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left, bottom: 10.0, right: 15.0)
        return newMargins
    }
    
    
    
    @IBAction func onNextBtnPressed(sender: AnyObject) {
        self.index = self.index + 1
        
        if self.index == feeds.count {
            self.index = 0
        }
        var feed : [String:AnyObject] = feeds[self.index] as Dictionary
        var title : String = feed["title"] as String
        println(title)
        self.titleLabel.text = title
        
    }
}
