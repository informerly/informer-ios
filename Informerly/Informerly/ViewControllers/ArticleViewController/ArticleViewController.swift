//
//  File.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import WebKit

class ArticleViewController : UIViewController,WKNavigationDelegate {
    
    var articleWebView : WKWebView!
    var articleZenView : UIWebView!
    var feeds : [Feeds.InformerlyFeed]!
    var articleIndex : Int!
    var webIndicator : UIActivityIndicatorView!
    var zenIndicator : UIActivityIndicatorView!
    var swipeDirection : String!
    var isZenMode : Bool!
    
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
        
        // Creates Article web view
        var frame : CGRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articleWebView = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
        articleWebView.navigationDelegate = self
        self.view.addSubview(articleWebView)
        
        // Creates Zen mode Web view
        articleZenView = UIWebView()
        articleZenView.frame = frame
        articleZenView.hidden = true
        self.view.addSubview(articleZenView)

        // Getting feeds from model
        self.feeds = Feeds.sharedInstance.getFeeds()
        
        // Load article in web and zen mode
        articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
        
        if feeds[articleIndex].content != nil {
            var content : String = feeds[articleIndex].content!
            articleZenView.loadHTMLString(content, baseURL: nil)
        }
        
        // Calls Read Web-Service
        self.markRead()
        
        //Article Web View Gestures 
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "onWebModeSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "onWebModeSwipe:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Activity indicator
        webIndicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2 - 25,self.view.frame.height/2 - 25, 50, 50)) as UIActivityIndicatorView
        webIndicator.hidesWhenStopped = true
        webIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(webIndicator)
        webIndicator.startAnimating()
        
        // Activity indicator
        zenIndicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2 - 25,self.view.frame.height/2 - 25, 50, 50)) as UIActivityIndicatorView
        zenIndicator.hidesWhenStopped = true
        zenIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(zenIndicator)
        
        swipeDirection = ""
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
            self.articleZenView.hidden = true
            
            if articleWebView.loading == false {
                self.articleWebView.hidden = false
                self.webIndicator.stopAnimating()
                self.webIndicator.hidesWhenStopped = true
            } else {
                self.webIndicator.hidden = false
                self.webIndicator.startAnimating()
            }
            
            self.articleWebView.frame = CGRectMake(-self.articleWebView.frame.width*2,
                self.articleWebView.frame.origin.y,
                self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
            
            UIView.animateWithDuration(0.50, animations: { () -> Void in
                self.articleWebView.frame = CGRectMake(0,
                    self.articleWebView.frame.origin.y,
                    self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
            })
            
            
        } else if sender.selectedSegmentIndex == 1 {
            
            isZenMode = true
            self.articleWebView.hidden = true
            self.webIndicator.hidden = true
            self.articleZenView.hidden = false
            
            self.articleZenView.frame = CGRectMake(self.articleZenView.frame.width*2,
                self.articleZenView.frame.origin.y,
                self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
            
            UIView.animateWithDuration(0.50, animations: { () -> Void in
                self.articleZenView.frame = CGRectMake(0,
                    self.articleZenView.frame.origin.y,
                    self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
            })
        }
    }
    
    
    // Web serivce to mark article as Read.
    func markRead() {
        var path : String = "links/\(feeds[articleIndex].id!)/read"
        var parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getStringForKey(AUTH_TOKEN),
                                               "client_id":"",
                                               "link_id": feeds[articleIndex].id!]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                println("Successfully marked as read.")
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                println("Failure marking article as read")
            }
    }
    
    // Gesture Recognizer
    func onWebModeSwipe(gesture:UIGestureRecognizer){
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                println("Swiped right")
                if articleIndex - Int(1) >= 0 {
                    if isZenMode == false {
                        self.webIndicator.startAnimating()
                    } else {
                        self.zenIndicator.startAnimating()
                    }
                    
                    self.swipeDirection = "Right"
                    articleIndex = articleIndex - Int(1)
                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                    articleWebView.hidden = true
                    
                    if feeds[articleIndex].content != nil {
                        var content: String = feeds[articleIndex].content!
                        articleZenView.loadHTMLString(content, baseURL: nil)
                        self.animateRightZenMode(articleZenView)
                        self.zenIndicator.stopAnimating()
                    }
                    self.markRead()
                }
            case UISwipeGestureRecognizerDirection.Left:
                println("Swiped left")
                if articleIndex + Int(1) < feeds.count {
                    if isZenMode == false {
                        self.webIndicator.startAnimating()
                    } else {
                        self.zenIndicator.startAnimating()
                    }
                    self.swipeDirection = "Left"
                    articleWebView.hidden = true
                    articleIndex = articleIndex + Int(1)
                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                    
                    if feeds[articleIndex].content != nil {
                        var content: String = feeds[articleIndex].content!
                        articleZenView.loadHTMLString(content, baseURL: nil)
                        self.animateLeftZenMode(articleZenView)
                        self.zenIndicator.stopAnimating()
                    }
                    self.markRead()
                }
            default:
                break
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
        
        articleWebView.hidden = false
        if self.swipeDirection == "Right" {
            self.animateRight(articleWebView)
        } else if self.swipeDirection == "Left" {
            self.animateLeft(articleWebView)
        }
    }
    
    
    // Methods to Animate WebView
    func animateRight(view : WKWebView) {
        view.frame = CGRectMake(-self.view.frame.width*2,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
        
        UIView.animateWithDuration(0.50, delay: 0.2, options: nil, animations: { () -> Void in
            view.frame = CGRectMake(0,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
            }, completion: {
                (value:Bool) in
            })
    }
    
    func animateLeft(view : WKWebView) {
        view.frame = CGRectMake(self.view.frame.width*2,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
        
        UIView.animateWithDuration(0.50, delay: 0.2, options: nil, animations: { () -> Void in
            view.frame = CGRectMake(0,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
            }, completion: { (value:Bool) in
                
            })
        
    }
    
    // Methods to Animate WebView
    func animateRightZenMode(view : UIWebView) {
        view.frame = CGRectMake(-self.view.frame.width*2,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
        
        UIView.animateWithDuration(0.50, delay: 0.2, options: nil, animations: { () -> Void in
            view.frame = CGRectMake(0,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
            }, completion: {
                (value:Bool) in
        })
    }
    
    func animateLeftZenMode(view : UIWebView) {
        view.frame = CGRectMake(self.view.frame.width*2,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
        
        UIView.animateWithDuration(0.50, delay: 0.2, options: nil, animations: { () -> Void in
            view.frame = CGRectMake(0,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
            }, completion: { (value:Bool) in
                
        })
        
    }
    
//    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
//        var JS : String = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);"
//        
//        webView.evaluateJavaScript(JS, completionHandler: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}