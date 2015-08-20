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
    @IBOutlet weak var openStoryBtn: UIButton!
    @IBOutlet weak var nextStoryBtn: UIButton!
    @IBOutlet weak var saveStoryBtn: UIButton!
    var feeds : [AnyObject]!
    var index : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        index = 0
        self.feeds = []
        
        // Apply border on buttons
        applyBorder(self.saveStoryBtn)
        applyBorder(self.openStoryBtn)
        applyBorder(self.nextStoryBtn)
        
        
        //Article Web View Gestures
//        var tap = UITapGestureRecognizer(target: self, action: "onTitleTap")
//        self.titleLabel.addGestureRecognizer(tap)
//        titleLabel.userInteractionEnabled = true
        
        var token : String! = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
        
        if token != nil && token != "" {
            var parameters = ["auth_token":token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath("feeds",
                parameter: parameters,
                success: { (requestStatus : Int32, processedData : AnyObject!, extraInfo : AnyObject!) -> Void in
                    if requestStatus == 200 {
                        var data : [AnyObject] = processedData["links"] as! Array
                        
                        var feed : [String:AnyObject]!
                        for feed in data {
                            if feed["read"] as! Bool == false && feed["bookmarked"] as! Bool == false {
                                self.feeds.append(feed)
                            }
                        }
                        
                        self.titleLabel.text = self.feeds[self.index]["title"] as? String
                        self.saveStoryBtn.hidden = false
                        self.openStoryBtn.hidden = false
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
    
    func applyBorder(button:UIButton) {
        button.layer.borderColor = UIColor(rgba: "#64ACFF").CGColor
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 5.0
    }
    
//    func onTitleTap() {
//        
//        if self.feeds != nil {
//            var feed : [String:AnyObject] = self.feeds[self.index] as! Dictionary
//            var id : Int = feed["id"] as! Int
//            
//            var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
//            userDefaults.setObject("\(id)", forKey: "id")
//            userDefaults.synchronize()
//            
//            var url =  NSURL(string:"TodayExtension://home")
//            self.extensionContext?.openURL(url!, completionHandler:{(success: Bool) -> Void in
//                println("task done!")
//            })
//        }
//    }
    
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
        var feed : [String:AnyObject] = feeds[self.index] as! Dictionary
        var title : String = feed["title"] as! String
        self.titleLabel.text = title
        
    }
    
    @IBAction func onOpenBtnPressed(sender: AnyObject) {
        if self.feeds != nil {
            var feed : [String:AnyObject] = self.feeds[self.index] as! Dictionary
            var id : Int = self.feeds[self.index]["id"] as! Int
            
            var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
            userDefaults.setObject("\(id)", forKey: "id")
            userDefaults.setBool(true, forKey: FROM_TODAY_WIDGET)
            userDefaults.synchronize()
            
            var url =  NSURL(string:"TodayExtension://home")
            self.extensionContext?.openURL(url!, completionHandler:{(success: Bool) -> Void in
                println("task done!")
            })
        }
    }
    
    
    @IBAction func onSaveBtnPressed(sender: AnyObject) {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            var link_id = self.feeds[self.index]["id"] as! Int
            var parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "link_id":"\(link_id)"]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        println("saved")
                        self.feeds.removeAtIndex(self.index)
                        if self.index != 0 {
                            self.index = self.index - 1
                        }
                        self.onNextBtnPressed("")
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    
                    if extraInfo != nil {
                        var error : [String:AnyObject] = extraInfo as! Dictionary
                        var message : String = error["error"] as! String
                    }
            }
        }
    }
    
}
