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
        
        
        var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.Informerly.informerWidget")!
        var token : String = userDefaults.stringForKey("auth_token")!
        
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
                }
            }) { (status : Int32, error : NSError!, extraInfo:AnyObject!) -> Void in
                println("error")
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        
        completionHandler(NCUpdateResult.NewData)
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
