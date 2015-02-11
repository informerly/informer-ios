//
//  File.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class ArticleViewController : UIViewController,UIWebViewDelegate,UITextViewDelegate {
    
    var articleWebView : UIWebView!
    var articleZenView : UITextView!
    var feeds : [Feeds.InformerlyFeed]!
    var articleIndex : Int!
    var actInd : UIActivityIndicatorView!
    var isSwiped : Bool!
    var swipeDirection : String!
    var isZenMode : Bool!
    
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
        articleZenView = UITextView()
        articleZenView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articleZenView.hidden = true
        articleZenView.delegate = self
        self.view.addSubview(articleZenView)
        
        self.feeds = Feeds.sharedInstance.getFeeds()
        
        articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
        
        if feeds[articleIndex].content != nil {
            var content : String = feeds[articleIndex].content!
            var data : NSData = content.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!
            var attributedString = NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
            articleZenView.attributedText = attributedString
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
        actInd = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
        actInd.startAnimating()
        isSwiped = false
        swipeDirection = ""
        isZenMode = false

    }
    
    func markRead() {
        var path : String = "links/\(feeds[articleIndex].id!)/read"
        var parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getStringForKey(AUTH_TOKEN),
                                               "client_id":"",
                                               "link_id": feeds[articleIndex].id!]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                println("Sucess")
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                println("Failure")
            }
    }
    
    
    func onZenModeswipe(gesture:UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                println("Swiped right")
                if self.articleIndex - Int(1) >= 0 {
                    self.articleIndex = articleIndex - Int(1)
                    
                    var content : String! = feeds[articleIndex].content!
                    if content != nil {
                        var data : NSData = content.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!
                        var attributedString = NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
                        articleZenView.attributedText = attributedString
                        self.animateRight(articleZenView)
                    }
                }

            case UISwipeGestureRecognizerDirection.Left:
                println("Swiped left")
                if self.articleIndex + Int(1) < feeds.count {
                    self.articleIndex = articleIndex + Int(1)
                    var content: String! = feeds[articleIndex].content!
                    if (content != nil) {
                        var data : NSData = content.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!
                        var attributedString = NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
                        articleZenView.attributedText = attributedString
                        self.animateLeft(articleZenView)
                    }
                }
            default:
                break
            }
        }
    }
    
    func animateRight(view : UITextView) {
        view.frame = CGRectMake(-self.view.frame.width*2,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
        
        UIView.animateWithDuration(0.40, animations: { () -> Void in
            view.frame = CGRectMake(0,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
        })
    }
    
    func animateLeft(view : UITextView) {
        view.frame = CGRectMake(self.view.frame.width*2,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
        
        UIView.animateWithDuration(0.40, animations: { () -> Void in
            view.frame = CGRectMake(0,view.frame.origin.y,view.frame.size.width, view.frame.size.height)
        })
    }
    
    
    func onWebModeSwipe(gesture:UIGestureRecognizer){
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                println("Swiped right")
                if articleIndex - Int(1) >= 0 {
                    self.actInd.startAnimating()
                    self.swipeDirection = "Right"
                    articleIndex = articleIndex - Int(1)
                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                    articleWebView.hidden = true
                    
                    if feeds[articleIndex].content == nil {
                        var content: String = feeds[articleIndex].content!
                        var data : NSData = content.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!
                        var attributedString = NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
                        articleZenView.attributedText = attributedString
                    }
                    
                }
            case UISwipeGestureRecognizerDirection.Left:
                println("Swiped left")
                if articleIndex + Int(1) < feeds.count {
                    self.actInd.startAnimating()
                    self.swipeDirection = "Left"
                    articleWebView.hidden = true
                    articleIndex = articleIndex + Int(1)
                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                    
                    if feeds[articleIndex].content != nil {
                        var content: String = feeds[articleIndex].content!
                        var data : NSData = content.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!
                        var attributedString = NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
                        articleZenView.attributedText = attributedString
                        self.animateLeft(articleZenView)
                    }
                    
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
            isZenMode = false
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
            
            self.actInd.stopAnimating()
            isZenMode = true
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
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        if webView.loading == true {
            return
        } else {
            var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("dataLoaded"), userInfo: nil, repeats: false)
        }
    }

    func dataLoaded() {
        
        println("finish")
        self.actInd.stopAnimating()
        
        if isZenMode == true {
            return
        }
        
        if self.swipeDirection == "Right" {
                
                self.articleWebView.hidden = false
                self.articleWebView.frame = CGRectMake(-self.articleWebView.frame.width*2,
                    self.articleWebView.frame.origin.y,
                    self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
                
                UIView.animateWithDuration(0.40, animations: { () -> Void in
                    self.articleWebView.frame = CGRectMake(0,
                        self.articleWebView.frame.origin.y,
                        self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
                })
                
//                self.articleZenView.frame = CGRectMake(-self.articleZenView.frame.width*2,
//                    self.articleZenView.frame.origin.y,
//                    self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
//                
//                UIView.animateWithDuration(0.40, animations: { () -> Void in
//                    self.articleZenView.frame = CGRectMake(0,
//                        self.articleZenView.frame.origin.y,
//                        self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
//                })
        } else if (self.swipeDirection == "Left") {
                
                self.articleWebView.hidden = false
                
//                self.articleZenView.frame = CGRectMake(self.articleZenView.frame.width*2,
//                    self.articleZenView.frame.origin.y,
//                    self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
//                
//                UIView.animateWithDuration(0.40, animations: { () -> Void in
//                    self.articleZenView.frame = CGRectMake(0,
//                        self.articleZenView.frame.origin.y,
//                        self.articleZenView.frame.size.width, self.articleZenView.frame.size.height)
//                })
            
                self.articleWebView.frame = CGRectMake(self.articleWebView.frame.width*2,
                    self.articleWebView.frame.origin.y,
                    self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
                
                UIView.animateWithDuration(0.40, animations: { () -> Void in
                    self.articleWebView.frame = CGRectMake(0,
                        self.articleWebView.frame.origin.y,
                        self.articleWebView.frame.size.width, self.articleWebView.frame.size.height)
                })
            }
        }
    
}