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
    
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prevStoryBtn: UIButton!
    @IBOutlet weak var nextStoryBtn: UIButton!
    @IBOutlet weak var saveStoryBtn: UIButton!
    @IBOutlet weak var readStoryBtn: UIButton!
    @IBOutlet weak var constraintNextBtnHorizontalSpacing: NSLayoutConstraint!
    @IBOutlet weak var constarintSaveBtnHorizontalSpacing: NSLayoutConstraint!
    var feeds : [AnyObject]!
    var index : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        if (self.view.frame.size.width == 320) {
            self.constraintNextBtnHorizontalSpacing.constant = self.constraintNextBtnHorizontalSpacing.constant - 10
            self.constarintSaveBtnHorizontalSpacing.constant = self.constraintNextBtnHorizontalSpacing.constant - 5
        } else if (self.view.frame.size.width == 375) {
            self.constraintNextBtnHorizontalSpacing.constant = self.constraintNextBtnHorizontalSpacing.constant + 5
            self.constarintSaveBtnHorizontalSpacing.constant = self.constraintNextBtnHorizontalSpacing.constant + 5
        } else {
            self.constraintNextBtnHorizontalSpacing.constant = self.constraintNextBtnHorizontalSpacing.constant + 10
            self.constarintSaveBtnHorizontalSpacing.constant = self.constraintNextBtnHorizontalSpacing.constant + 10
        }
        
        index = 0
        self.feeds = []
        
        containingView.layer.borderColor = UIColor(rgba: "#64ACFF").CGColor
        containingView.layer.borderWidth = 1.0
        
        // Apply border on buttons
        applyBorder(self.prevStoryBtn)
        applyBorder(self.nextStoryBtn)
        applyBorder(self.saveStoryBtn)
        applyBorder(self.readStoryBtn)
        
        
        //Article Web View Gestures
        var tap = UITapGestureRecognizer(target: self, action: "onTitleTap")
        self.titleLabel.addGestureRecognizer(tap)
        titleLabel.userInteractionEnabled = true
        
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
                            if feed["read"] as! Bool == false {
                                self.feeds.append(feed)
                            }
                        }
                        
                        self.titleLabel.text = self.feeds[self.index]["title"] as? String
                        if self.feeds[self.index]["bookmarked"] as? Bool == true {
                            self.saveStoryBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
                        }
                        self.prevStoryBtn.hidden = false
                        self.prevStoryBtn.enabled = false
                        self.nextStoryBtn.hidden = false
                        self.saveStoryBtn.hidden = false
                        self.readStoryBtn.hidden = false
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
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 20.0
    }
    
    func onTitleTap() {
        
        if self.feeds != nil {
            var feed : [String:AnyObject] = self.feeds[self.index] as! Dictionary
            var id : Int = feed["id"] as! Int
            
            var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
            userDefaults.setObject("\(id)", forKey: "id")
            userDefaults.synchronize()
            
            var url =  NSURL(string:"TodayExtension://home")
            self.extensionContext?.openURL(url!, completionHandler:{(success: Bool) -> Void in
                println("task done!")
            })
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
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var newMargins : UIEdgeInsets = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left, bottom: 10.0, right: 15.0)
        return newMargins
    }
    
    
    @IBAction func onPrevBtnPressed(sender: AnyObject) {
        self.index = self.index - 1
        
        if self.index == 0 {
            self.prevStoryBtn.enabled = false
        } else {
            self.prevStoryBtn.enabled = true
            self.nextStoryBtn.enabled = true
        }
        
        var feed : [String:AnyObject] = feeds[self.index] as! Dictionary
        var title : String = feed["title"] as! String
        self.titleLabel.text = title
        
        if self.feeds[self.index]["bookmarked"] as? Bool == true {
            self.saveStoryBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
        } else {
            self.saveStoryBtn.setImage(UIImage(named: ICON_BOOKMARK_BLUE)!, forState: UIControlState.Normal)
        }
        
    }
    
    @IBAction func onNextBtnPressed(sender: AnyObject) {
        self.index = self.index + 1
        
        if self.index == feeds.count {
            self.nextStoryBtn.enabled = false
        } else {
            self.nextStoryBtn.enabled = true
            self.prevStoryBtn.enabled = true
            
            var feed : [String:AnyObject] = feeds[self.index] as! Dictionary
            var title : String = feed["title"] as! String
            self.titleLabel.text = title
            
            if self.feeds[self.index]["bookmarked"] as? Bool == true {
                self.saveStoryBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
            } else {
                self.saveStoryBtn.setImage(UIImage(named: ICON_BOOKMARK_BLUE)!, forState: UIControlState.Normal)
            }
        }
        
    }
    
//    @IBAction func onOpenBtnPressed(sender: AnyObject) {
//        if self.feeds != nil {
//            var feed : [String:AnyObject] = self.feeds[self.index] as! Dictionary
//            var id : Int = self.feeds[self.index]["id"] as! Int
//            
//            var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
//            userDefaults.setObject("\(id)", forKey: "id")
//            userDefaults.setBool(true, forKey: FROM_TODAY_WIDGET)
//            userDefaults.synchronize()
//            
//            var url =  NSURL(string:"TodayExtension://home")
//            self.extensionContext?.openURL(url!, completionHandler:{(success: Bool) -> Void in
//                println("task done!")
//            })
//        }
//    }
    
    @IBAction func onReadBtnPressed(sender: AnyObject) {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            
            var articleID = self.feeds[self.index]["id"] as! Int
            var parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
                "client_id":"",
                "link_id": articleID]
            
            var path = "links/\(articleID)/read"
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    println("Successfully marked as read.")
                    self.feeds.removeAtIndex(self.index)
                    self.index = self.index - 1
                    if self.index <= 0 {
                        self.index = 0
                        self.prevStoryBtn.enabled = false
                    }
                    
                    var feed : [String:AnyObject] = self.feeds[self.index] as! Dictionary
                    var title : String = feed["title"] as! String
                    self.titleLabel.text = title
                    
                    if self.feeds[self.index]["bookmarked"] as? Bool == true {
                        self.saveStoryBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
                    } else {
                        self.saveStoryBtn.setImage(UIImage(named: ICON_BOOKMARK_BLUE)!, forState: UIControlState.Normal)
                    }

                    
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    println("Failure marking article as read")
            }
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
                        self.saveStoryBtn.setImage(UIImage(named: ICON_BOOKMARK_FILLED)!, forState: UIControlState.Normal)
//                        self.feeds.removeAtIndex(self.index)
//                        if self.index != 0 {
//                            self.index = self.index - 1
//                        }
//                        self.onNextBtnPressed("")
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
