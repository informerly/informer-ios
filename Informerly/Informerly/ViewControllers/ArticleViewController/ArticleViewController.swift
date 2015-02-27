//
//  File.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import WebKit

class ArticleViewController : UIViewController,WKNavigationDelegate,UIScrollViewDelegate {
    
    var articleWebView : WKWebView!
    var zenModeScrollView : UIScrollView!
    var feeds : [Feeds.InformerlyFeed]!
    var articleIndex : Int!
    var webIndicator : UIActivityIndicatorView!
    var isZenMode : Bool!
    var isStarted : Bool!
    var zenModeWebViewX : CGFloat!
    
    let ANIMATION_DURATION = 1.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setting up Nav bar
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.hidesBackButton = true
        self.createNavBarButtons()
        self.createSegmentedControl()
        
        // Calculating origin for webview
        var statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        var navBarHeight = self.navigationController?.navigationBar.frame.height
        var resultantHeight = statusBarHeight + navBarHeight!
        
        // Getting feeds from model
        self.feeds = Feeds.sharedInstance.getFeeds()
        
        // Creates Article web view
        var frame : CGRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articleWebView = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
        articleWebView.navigationDelegate = self
        articleWebView.alpha = 0.0
        self.view.addSubview(articleWebView)
        
        // Load article in web and zen mode
        articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
        
        // Create Zen mode ScrollView
        var rect : CGRect = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - resultantHeight)
        self.zenModeScrollView = UIScrollView(frame: rect)
        self.zenModeScrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(self.feeds.count) , self.view.frame.height - resultantHeight)
        self.zenModeScrollView.pagingEnabled = true
        self.zenModeScrollView.delegate = self
        self.zenModeScrollView.alpha = 0.0
        self.view.addSubview(self.zenModeScrollView)
        
        self.zenModeWebViewX = 0
        for var i=0; i<self.feeds.count; i++ {
            // Creates Zen mode Web view
            var frame : CGRect = CGRectMake(self.zenModeWebViewX, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
            var articleZenView : UIWebView = UIWebView()
            articleZenView.frame = frame
            self.zenModeScrollView.addSubview(articleZenView)
            
            if feeds[i].content != nil {
                var content : String = feeds[i].content!
                articleZenView.loadHTMLString(content, baseURL: nil)
            }
            
            self.zenModeWebViewX = self.zenModeWebViewX + self.view.frame.width

        }
        
        //Calls Read Web-Service
        self.markRead()
        
        // Activity indicator
        webIndicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2 - 50, 0, 0)) as UIActivityIndicatorView
        webIndicator.hidesWhenStopped = true
        webIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(webIndicator)
        webIndicator.startAnimating()
        
        isZenMode = false

    }
    
    // Creates bar button for navbar
    func createNavBarButtons() {
        var back_btn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onBackPressed"))
        
        back_btn.tintColor = UIColor.grayColor()
        self.navigationItem.leftBarButtonItem = back_btn
        
        var shareBarBtnItem : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "share_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onSharePressed"))
        shareBarBtnItem.tintColor = UIColor.grayColor()
        self.navigationItem.rightBarButtonItem = shareBarBtnItem
    }
    
    // Creates Segemted control
    func createSegmentedControl() {
        var customSegmentedControl = UISegmentedControl (items: ["Web","Zen"])
        customSegmentedControl.frame = CGRectMake(0, 0,130, 30)
        customSegmentedControl.selectedSegmentIndex = 0
        customSegmentedControl.addTarget(self, action: "segmentedValueChanged:", forControlEvents: .ValueChanged)
        
        self.navigationItem.titleView = customSegmentedControl
    }
    
    // segemented control call back
    func segmentedValueChanged(sender:UISegmentedControl!)
    {
        if sender.selectedSegmentIndex == 0 {
            isZenMode = false
            self.zenModeScrollView.alpha = 0.0
            
            if articleWebView.loading == false {
                UIView.animateWithDuration(ANIMATION_DURATION, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.articleWebView.alpha = 1.0
                    }, completion: nil)
                self.webIndicator.stopAnimating()
                self.webIndicator.hidesWhenStopped = true
            } else {
                self.webIndicator.hidden = false
                self.webIndicator.startAnimating()
            }
            
        } else if sender.selectedSegmentIndex == 1 {
            
            isZenMode = true
            self.articleWebView.alpha = 0.0
            self.webIndicator.hidden = true
            
            self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(articleIndex)
            
            UIView.animateWithDuration(ANIMATION_DURATION, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.zenModeScrollView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    
    // Web serivce to mark article as Read.
    func markRead() {
        
        self.feeds[self.articleIndex].read = true
        
        var path : String = "links/\(feeds[articleIndex].id!)/read"
        var parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
                                               "client_id":"",
                                               "link_id": feeds[articleIndex].id!]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                println("Successfully marked as read.")
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                println("Failure marking article as read")
                
                if extraInfo != nil {
                    var error : [String:AnyObject] = extraInfo as Dictionary
                    var message : String = error["error"] as String
                    
                    if message == "Invalid authentication token." {
                        var alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as LoginViewController
                            self.showViewController(loginVC, sender: self)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
    }
    
    
    func onBackPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onSharePressed() {
        var sharingItems = [AnyObject]()
        sharingItems.append(feeds[articleIndex].title!)
        sharingItems.append(feeds[articleIndex].URL!)
        
        let activityVC = UIActivityViewController(activityItems:sharingItems, applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // Web view delegate
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        println("finish")
        webIndicator.stopAnimating()
        articleWebView.alpha = 1.0
    }
    
    
    // UIScrollView Delegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var pageWidth : CGFloat = self.view.frame.width
        var page : CGFloat = scrollView.contentOffset.x / pageWidth
        articleIndex = Int(page)
        
        // Load article in web and zen mode
        articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
        self.markRead()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}