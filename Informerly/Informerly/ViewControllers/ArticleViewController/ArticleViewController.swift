//
//  File.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class ArticleViewController : UIViewController,UIWebViewDelegate {
    
    var articleWebView : UIWebView!
    var articleZenView : UIWebView!
    var feeds : [Feeds.InformerlyFeed]!
    var articleIndex : Int!
    var actInd : UIActivityIndicatorView!
    var isSwiped : Bool!
    var swipeDirection : String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setting up Nav bar
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.hidesBackButton = true
        self.createNavBarButtons()
        self.createSegmentedControl()
        
        var statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        var navBarHeight = self.navigationController?.navigationBar.frame.height
        var resultantHeight = statusBarHeight + navBarHeight!
        
        // Creates Artical web view
        articleWebView = UIWebView()
        articleWebView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articleWebView.scalesPageToFit = true
        articleWebView.delegate = self
        self.view.addSubview(articleWebView)
        
        //Creates Zen mode Web view
        articleZenView = UIWebView()
        articleZenView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articleZenView.hidden = true
        articleZenView.delegate = self
        self.view.addSubview(articleZenView)
        
        self.feeds = Feeds.sharedInstance.getFeeds()
        
        articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
        articleZenView.loadHTMLString(feeds[articleIndex].content, baseURL: nil)
        
        //Article Web View Gestures 
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "onWebViewSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "onWebViewSwipe:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        
//        // Activity indicator
//        actInd = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2, 50, 50)) as UIActivityIndicatorView
//        actInd.center = self.view.center
//        actInd.hidesWhenStopped = true
//        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//        view.addSubview(actInd)
//        actInd.startAnimating()
//        isSwiped = false

    }
    
    
    func onWebViewSwipe(gesture:UIGestureRecognizer){
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                println("Swiped right")
                self.swipeDirection = "Right"
                if articleIndex - Int(1) >= 0 {
                    
                    articleIndex = articleIndex - Int(1)
                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                    articleZenView.loadHTMLString(feeds[articleIndex].content, baseURL: nil)
                    
                    self.articleWebView.frame = CGRectMake(-self.articleWebView.frame.width*2,
                        self.articleWebView.frame.origin.y,
                        self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
                    
                    UIView.animateWithDuration(0.40, animations: { () -> Void in
                        self.articleWebView.frame = CGRectMake(0,
                            self.articleWebView.frame.origin.y,
                            self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
                    })
                    
                    self.articleZenView.frame = CGRectMake(-self.articleZenView.frame.width*2,
                        self.articleZenView.frame.origin.y,
                        self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
                    
                    UIView.animateWithDuration(0.40, animations: { () -> Void in
                        self.articleZenView.frame = CGRectMake(0,
                            self.articleZenView.frame.origin.y,
                            self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
                    })
                    
                }
            case UISwipeGestureRecognizerDirection.Left:
                println("Swiped left")
                self.swipeDirection = "Left"
                if articleIndex + Int(1) < feeds.count {

                    articleIndex = articleIndex + Int(1)
                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                    articleZenView.loadHTMLString(feeds[articleIndex].content, baseURL: nil)
                    
                    self.articleZenView.frame = CGRectMake(self.articleZenView.frame.width*2,
                        self.articleZenView.frame.origin.y,
                        self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
                    
                    UIView.animateWithDuration(0.40, animations: { () -> Void in
                        self.articleZenView.frame = CGRectMake(0,
                            self.articleZenView.frame.origin.y,
                            self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
                    })
                    
                    self.articleWebView.frame = CGRectMake(self.articleWebView.frame.width*2,
                        self.articleWebView.frame.origin.y,
                        self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
                    
                    UIView.animateWithDuration(0.40, animations: { () -> Void in
                        self.articleWebView.frame = CGRectMake(0,
                            self.articleWebView.frame.origin.y,
                            self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
                    })
                }
            default:
                break
            }
        }
    }

    
    
    func createNavBarButtons() {
        var back_btn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onBackPressed"))
        
        back_btn.tintColor = UIColor.grayColor()
        self.navigationItem.leftBarButtonItem = back_btn
        
        var shareBarBtnItem : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "share_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onSharePressed"))
        shareBarBtnItem.tintColor = UIColor.grayColor()
        self.navigationItem.rightBarButtonItem = shareBarBtnItem
    }
    
    func createSegmentedControl() {
        var customSegmentedControl = UISegmentedControl (items: ["Web","Zen"])
        customSegmentedControl.frame = CGRectMake(0, 0,130, 30)
        customSegmentedControl.selectedSegmentIndex = 0
        customSegmentedControl.addTarget(self, action: "segmentedValueChanged:", forControlEvents: .ValueChanged)
        
        self.navigationItem.titleView = customSegmentedControl
    }
    
    func segmentedValueChanged(sender:UISegmentedControl!)
    {
        if sender.selectedSegmentIndex == 0 {
            self.articleZenView.hidden = true
            self.articleWebView.hidden = false
            
            self.articleWebView.frame = CGRectMake(-self.articleWebView.frame.width*2,
                self.articleWebView.frame.origin.y,
                self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
            
            UIView.animateWithDuration(0.40, animations: { () -> Void in
                self.articleWebView.frame = CGRectMake(0,
                    self.articleWebView.frame.origin.y,
                    self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
            })
            
            
        } else if sender.selectedSegmentIndex == 1 {
            
            self.articleWebView.hidden = true
            self.articleZenView.hidden = false
            
            self.articleZenView.frame = CGRectMake(self.articleZenView.frame.width*2,
                self.articleZenView.frame.origin.y,
                self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
            
            UIView.animateWithDuration(0.40, animations: { () -> Void in
                self.articleZenView.frame = CGRectMake(0,
                    self.articleZenView.frame.origin.y,
                    self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
            })
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        println("start")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        println("finish")
        //self.actInd.stopAnimating()
        
//        if isSwiped == true {
//            if swipeDirection == "Right" {
//            
//            }
//            
//            if swipeDirection == "Left" {
//                
//            }
//        }
    }
    
}