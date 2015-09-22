//
//  File.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import WebKit

class ArticleViewController : UIViewController,WKNavigationDelegate,UIScrollViewDelegate,UIWebViewDelegate {
    
    var articleWebView : WKWebView!
    var zenModeScrollView : UIScrollView!
    var feeds : [InformerlyFeed]!
    var unreadFeeds : [InformerlyFeed]!
    var categoryFeeds : [InformerlyFeed]!
    var unreadbookmarkedFeeds : [BookmarkFeed]!
    var bookmarkedFeeds : [BookmarkFeed]!
    var isUnreadTab : Bool!
    var isBookmarked : Bool!
    var isCategoryFeeds : Bool!
    var articleIndex : Int!
    var isZenMode : Bool!
    var isStarted : Bool!
    var zenModeWebViewX : CGFloat!
    var readArticles : [Int]!
    var zenModeBtnView : UIView!
    var customSegmentedControl : UISegmentedControl!
    var progressTimer : NSTimer!
    var tintColor : UIColor!
    var lastContentOffset : CGFloat = 1.0
    var lastContentOffsetX : CGFloat = 0.0
    var toolbar : UIToolbar!
    var bookmark : UIBarButtonItem!
    var leftArrow : UIBarButtonItem!
    var rightArrow : UIBarButtonItem!
    var feedData : InformerlyFeed!
    var resultantHeight : CGFloat = 0.0
    var zenWebViews : [UIWebView?] = []
    var isFromNextORPrev = true
    var isFromFeeds : Bool!
    
    let ANIMATION_DURATION = 1.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Application did become active
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"appDidBecomeActiveCalled", name:UIApplicationDidBecomeActiveNotification, object: nil)
        
        // Setting up Nav bar
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.hidesBackButton = true
        self.createNavBarButtons()
        self.createSegmentedControl()
        
        // Calculating origin for webview
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navBarHeight = self.navigationController?.navigationBar.frame.height
        self.resultantHeight = statusBarHeight + navBarHeight!
        
        if ( Utilities.sharedInstance.getBoolForKey(IS_FROM_CUSTOM_URL) == true || self.isFromFeeds == false) {
            self.feeds = [self.feedData]
            self.articleIndex = 0
        } else if (Utilities.sharedInstance.getBoolForKey(IS_FROM_PUSH) == true){
            if self.isCategoryFeeds == true {
                self.feeds = self.categoryFeeds
            } else {
                self.feeds = Feeds.sharedInstance.getFeeds()
            }
            Utilities.sharedInstance.setBoolForKey(false, key: IS_FROM_PUSH)
        } else if (Utilities.sharedInstance.getBoolForAppGroupKey(FROM_TODAY_WIDGET)) {
            self.feeds = Feeds.sharedInstance.getFeeds()
            Utilities.sharedInstance.setBoolAppGroupForKey(false, key: FROM_TODAY_WIDGET)
        } else {
            if isUnreadTab == true && isBookmarked == false {
                self.feeds = unreadFeeds
            } else if isUnreadTab == true && isBookmarked == true {
                self.bookmarkedFeeds = unreadbookmarkedFeeds
                self.feeds = Feeds.sharedInstance.getFeeds()
            } else if isBookmarked == true {
                self.bookmarkedFeeds = CoreDataManager.getBookmarkFeeds()
                self.feeds = Feeds.sharedInstance.getFeeds()
            } else if isCategoryFeeds == true {
                self.feeds = self.categoryFeeds
            } else {
                self.feeds = Feeds.sharedInstance.getFeeds()
            }
        }
        
        // Creates Article web view
        let frame : CGRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articleWebView = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
        articleWebView.navigationDelegate = self
        articleWebView.scrollView.delegate = self
        articleWebView.alpha = 0.0
        self.view.addSubview(articleWebView)
        
        // Create Zen mode Button
        self.createZenModeButton()
        
        // Create progress bar
        self.createProgressBar()
        
        var count = 0
        // Load article in web and zen mode
        if isBookmarked == true {
            
            if self.bookmarkedFeeds != nil {
                count = self.bookmarkedFeeds.count
            } else {
                self.bookmarkedFeeds = CoreDataManager.getBookmarkFeeds()
                count = self.bookmarkedFeeds.count
            }
            
            articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: bookmarkedFeeds[articleIndex].url!)!))
        } else {
            count = self.feeds.count
            
            if articleIndex > count {
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: Feeds.sharedInstance.getFeeds()[articleIndex].URL!)!))
            } else {
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
            }
        }
        
        self.zenWebViews = [UIWebView?](count: count, repeatedValue: nil)
        self.markRead()
        
        // Create Zen mode ScrollView
        let rect : CGRect = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - resultantHeight)
        self.zenModeScrollView = UIScrollView(frame: rect)
        self.zenModeScrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(count) , self.view.frame.height - resultantHeight)
        self.zenModeScrollView.pagingEnabled = true
        self.zenModeScrollView.delegate = self
        self.zenModeScrollView.alpha = 0.0
        self.view.addSubview(self.zenModeScrollView)
        
        self.zenModeWebViewX = 0
        self.readArticles = [Int]()
        
        // Create Toolbar
        self.createToolBar()
        
        if self.articleIndex > 0 {
            self.createZenWebView(self.articleIndex - 1)
            self.createZenWebView(self.articleIndex - 2)
        }
        
        self.createZenWebView(self.articleIndex)
        self.createZenWebView(self.articleIndex + 1)
        self.createZenWebView(self.articleIndex + 2)
        self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(articleIndex)
        
        isZenMode = false

        Utilities.sharedInstance.setBoolForKey(false, key: IS_FROM_CUSTOM_URL)
        
        if Utilities.sharedInstance.getStringForKey(DEFAULT_ARTICLE_VIEW) == "zen" {
            isZenMode = true
            customSegmentedControl.selectedSegmentIndex = 1
            toolbar.alpha = 1.0
            self.progressTimer.invalidate()
            self.navigationController?.cancelSGProgress()
            self.articleWebView.alpha = 0.0
            self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(articleIndex)
            self.zenModeScrollView.alpha = 1.0
            self.view.bringSubviewToFront(toolbar)
        }
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
////
////        let shareMenu : UIMenuItem = UIMenuItem(title: "Share", action: Selector("onTextShare:"))
////        UIMenuController.sharedMenuController().menuItems = [shareMenu]
//    }
//
//    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
////        print(UIMenuController.sharedMenuController().menuItems?.first?)
//        if action == Selector("share:") {
//            return true
//        }
//        
//        return super.canPerformAction(action, withSender: sender)
//    }
//    
//    func share(sender:AnyObject?){
//        
//        var selectedText : String?
//        var sharingItems = [AnyObject]()
//        var url : String!
//        var subject : String!
//        if isBookmarked == true {
//            subject = self.bookmarkedFeeds[articleIndex].title!
//            url = self.bookmarkedFeeds[articleIndex].url!
//        } else if isCategoryFeeds == true {
//            subject = self.categoryFeeds![articleIndex].title!
//            url = self.categoryFeeds![articleIndex].URL!
//        } else {
//            subject = feeds[articleIndex].title!
//            url = self.feeds[articleIndex].URL!
//        }
//        
//        if self.isZenMode == true {
//            selectedText = self.zenWebViews[self.articleIndex]?.stringByEvaluatingJavaScriptFromString("window.getSelection().toString()")
//            
//            if selectedText != nil {
//                sharingItems.append("\(selectedText!) \n \n")
//            }
//            sharingItems.append(url)
//            
//            let activity = ARSafariActivity()
//            let activityVC = UIActivityViewController(activityItems:sharingItems, applicationActivities: [activity])
//            activityVC.setValue(subject, forKey: "subject")
//            self.presentViewController(activityVC, animated: true, completion: nil)
//        } else {
//            self.articleWebView.evaluateJavaScript("window.getSelection().toString()", completionHandler: { (seletectString, error) -> Void in
//                selectedText = seletectString as? String
//                
//                if selectedText != nil {
//                    sharingItems.append("\(selectedText!) \n \n")
//                }
//                sharingItems.append(url)
//                
//                let activity = ARSafariActivity()
//                let activityVC = UIActivityViewController(activityItems:sharingItems, applicationActivities: [activity])
//                activityVC.setValue(subject, forKey: "subject")
//                self.presentViewController(activityVC, animated: true, completion: nil)
//            })
//        }
//    }
    
    // Creates bar button for navbar
    func createNavBarButtons() {
        let back_btn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onBackPressed"))
        
        back_btn.tintColor = UIColor.grayColor()
        self.navigationItem.leftBarButtonItem = back_btn
    }
    
    // Creates Segemted control
    func createSegmentedControl() {
        customSegmentedControl = UISegmentedControl (items: ["Web","Zen"])
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
                self.zenModeBtnView.hidden = true
                toolbar.alpha = 1.0
                self.view.bringSubviewToFront(toolbar)
            } else {
                toolbar.alpha = 0.0
                self.zenModeBtnView.hidden = false
                self.createProgressBar()
            }
            
        } else if sender.selectedSegmentIndex == 1 {
            
            isZenMode = true
            self.articleWebView.alpha = 0.0
            toolbar.alpha = 1.0
            self.progressTimer.invalidate()
            self.navigationController?.cancelSGProgress()
            self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(articleIndex)
            
            UIView.animateWithDuration(ANIMATION_DURATION, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.zenModeScrollView.alpha = 1.0
                }, completion: nil)
            self.view.bringSubviewToFront(toolbar)
        }
    }
    
    // create zenModeButton
    func createZenModeButton(){
        let zenModeBtnViewRect : CGRect = CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-110,
            200, 100)
        self.zenModeBtnView = UIView(frame: zenModeBtnViewRect)
        self.view.addSubview(zenModeBtnView)
        
        let zenCloudImageView : UIImageView = UIImageView(image: UIImage(named: "zen_cloud"))
        zenCloudImageView.frame = CGRectMake(zenModeBtnView.frame.size.width/2 - zenCloudImageView.frame.size.width/2,
            0, zenCloudImageView.frame.size.width, zenCloudImageView.frame.size.height)
        zenModeBtnView.addSubview(zenCloudImageView)
        
        let zenModeBtn : UIButton = UIButton(type: UIButtonType.System)
        zenModeBtn.setImage(UIImage(named: "zen_btn"), forState: UIControlState.Normal)
        zenModeBtn.frame = CGRectMake(zenModeBtnView.frame.size.width/2 - 85,zenCloudImageView.frame.size.height + 10, 170,55)
        zenModeBtn.addTarget(self, action: Selector("onZenModeBtnPress:"), forControlEvents: UIControlEvents.TouchUpInside)
        zenModeBtnView.addSubview(zenModeBtn)
    }
    
    
    func createZenWebView(index : Int){
        
        if index >= 0 && index < self.zenWebViews.count && self.zenWebViews[index] == nil {
            // Creates Zen mode Web view
            self.zenModeWebViewX = CGFloat(index) * self.view.frame.width
            let frame : CGRect = CGRectMake(self.zenModeWebViewX, 0, self.view.frame.size.width, self.view.frame.height)
            let articleZenView : UIWebView = UIWebView()
            articleZenView.delegate = self
            articleZenView.frame = frame
            articleZenView.scrollView.delegate = self
            self.zenModeScrollView.addSubview(articleZenView)
            
            if isBookmarked == true {
                if bookmarkedFeeds[index].content != nil {
                    let content : String = bookmarkedFeeds[index].content!
                    articleZenView.loadHTMLString(content, baseURL: nil)
                }
                
            } else {
                if feeds[index].content != nil {
                    let content : String = feeds[index].content!
                    articleZenView.loadHTMLString(content, baseURL: nil)
                }
            }
            
            self.zenWebViews[index] = articleZenView

        }
    }
    
    func removeZenWebView(index:Int){
        
        if  index >= 0 && index < self.zenWebViews.count && self.zenWebViews[index] != nil {
            let webView : UIWebView = self.zenWebViews[index]!
            webView.removeFromSuperview()
            self.zenWebViews[index] = nil
        }
        
    }
    
    func createProgressBar(){
        
        if self.progressTimer != nil {
            self.progressTimer.invalidate()
        }
        
        self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("progressWithPercentage"), userInfo: nil, repeats: true)
    }
    
    func progressWithPercentage() {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            let percentage : Float = Float(self.articleWebView.estimatedProgress)
            if percentage == 1.0 {
                self.navigationController?.cancelSGProgress()
                self.progressTimer.invalidate()
            }
            
            if !self.isZenMode {
                self.navigationController?.setSGProgressPercentage(percentage * 100, andTintColor:UIColor(red: 44/255, green: 123/255, blue: 254/255, alpha: 1))
            } else {
                self.navigationController?.setSGProgressPercentage(percentage * 100, andTintColor: UIColor.clearColor())
            }
        })
    }
    
    func createToolBar(){
        
        toolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44 - 64, self.view.frame.size.width, 44))
        toolbar.alpha = 0.0
        
        leftArrow = UIBarButtonItem(image: UIImage(named: "icon_left_arrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onPrev"))
        
        let flexibleItem1 : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        rightArrow = UIBarButtonItem(image: UIImage(named: "icon_right_arrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onNext"))
        
        let flexibleItem2 : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)

        var img : UIImage? = UIImage(named: ICON_BOOKMARK)
        
        if isBookmarked == true {
            img = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            if articleIndex + 1 == self.bookmarkedFeeds.count {
                rightArrow.enabled = false
            }
        } else {
            if feeds[articleIndex].bookmarked == true {
                img = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
            
            if articleIndex + 1 == self.feeds.count {
                rightArrow.enabled = false
            }
        }
        
        bookmark = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onBookmark"))
        
        let flexibleItem3 : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)

        let share : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: ICON_SHARE), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onSharePressed"))
        
        toolbar.tintColor = UIColor(rgba: "#A6A8AB")
        
        var items  = [UIBarButtonItem]()
        items.append(leftArrow)
        items.append(flexibleItem1)
        items.append(rightArrow)
        items.append(flexibleItem2)
        items.append(bookmark)
        items.append(flexibleItem3)
        items.append(share)
        
        toolbar.setItems(items, animated: true)
        self.view.addSubview(toolbar)
        
        
        if articleIndex == 0 {
            leftArrow.enabled = false
        }
        
        if Utilities.sharedInstance.getBoolForKey(IS_FROM_CUSTOM_URL) {
            leftArrow.enabled = false
            rightArrow.enabled = false
        }
        
    }
    
    // Web serivce to mark article as Read.
    func markRead() {
        
        var path : String!
        var articleID : Int!
        
        if isBookmarked == true {
            self.bookmarkedFeeds[self.articleIndex].read = true
            path = "links/\(bookmarkedFeeds[articleIndex].id!)/read"
            articleID = bookmarkedFeeds[articleIndex].id!
        } else {
            self.feeds[self.articleIndex].read = true
            path = "links/\(feeds[articleIndex].id!)/read"
            articleID = feeds[articleIndex].id!
        }
        
        let parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
            "client_id":"",
            "link_id": articleID]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                print("Successfully marked as read.")
                
                if self.isBookmarked == true {
                    CoreDataManager.updateReadStatusForFeedID(self.bookmarkedFeeds[self.articleIndex].id!, readStatus: true)
                }
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                print("Failure marking article as read")
                
                var readArticles:[Int]!
                if NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) == nil {
                    readArticles = [Int]()
                } else {
                    readArticles = NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) as! Array
                }
                if self.isBookmarked == true {
                    readArticles.append(self.bookmarkedFeeds[self.articleIndex].id!)
                } else {
                    readArticles.append(self.feeds[self.articleIndex].id!)
                }
                
                NSUserDefaults.standardUserDefaults().setObject(readArticles, forKey: READ_ARTICLES)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                if extraInfo != nil {
                    var error : [String:AnyObject] = extraInfo as! Dictionary
                    let message : String = error["error"] as! String
                    
                    if message == "Invalid authentication token." {
                        let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                            self.showViewController(loginVC, sender: self)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
        }
    }
    
    func onBackPressed() {
        articleWebView.navigationDelegate = nil
        articleWebView.scrollView.delegate = nil
        self.navigationController?.cancelSGProgress()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onSharePressed() {
        var sharingItems = [AnyObject]()
        var url : NSURL!
        if isBookmarked == true {
            sharingItems.append(self.bookmarkedFeeds[articleIndex].title!)
            url = NSURL(string: bookmarkedFeeds[articleIndex].url!)
        } else if isCategoryFeeds == true {
            sharingItems.append(self.categoryFeeds![articleIndex].title!)
            url = NSURL(string: self.categoryFeeds![articleIndex].URL!)
        } else {
            sharingItems.append(feeds[articleIndex].title!)
            url = NSURL(string: feeds[articleIndex].URL!)
        }
        
        sharingItems.append(url)
        
        let activity = ARSafariActivity()
        let activityVC = UIActivityViewController(activityItems:sharingItems, applicationActivities: [activity])
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // Web view delegate
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("finish")
//        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)
        self.zenModeBtnView.hidden = true
        articleWebView.alpha = 1.0
        toolbar.alpha = 1.0
    }
    
    
    // UIScrollView Delegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
        lastContentOffsetX = scrollView.contentOffset.x
        if scrollView.contentOffset.y == 0.0 {
            lastContentOffset = 1.0
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if lastContentOffset < scrollView.contentOffset.y {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.toolbar.frame = CGRectMake(0, self.view.frame.size.height + 44, self.view.frame.size.width, 44)
            })
            
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)
            })
        }
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if isZenMode == true {
            isFromNextORPrev = false
            if lastContentOffsetX < scrollView.contentOffset.x || lastContentOffsetX > scrollView.contentOffset.x  {
                
                if lastContentOffsetX < scrollView.contentOffset.x {
                    onNext()
                    isFromNextORPrev = true
                } else {
                    onPrev()
                    isFromNextORPrev = true
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        if isZenMode == true {
//            
//            if lastContentOffsetX < scrollView.contentOffset.x || lastContentOffsetX > scrollView.contentOffset.x  {
//                var pageWidth : CGFloat = self.view.frame.width
//                var page : CGFloat = scrollView.contentOffset.x / pageWidth
////                articleIndex = Int(page)
//                
//                if lastContentOffsetX < scrollView.contentOffset.x {
//                    self.onNext()
////                    self.removeZenWebView(self.articleIndex - 3)
////                    self.createZenWebView(self.articleIndex + 2)
//                } else {
//                    self.onPrev()
////                    self.removeZenWebView(self.articleIndex + 3)
////                    self.createZenWebView(self.articleIndex - 2)
//                }
//                
////                if articleIndex == 0 {
////                    leftArrow.enabled = false
////                } else {
////                    leftArrow.enabled = true
////                }
////                
////                if isBookmarked == true {
////                    
////                    if articleIndex == bookmarkedFeeds.count - 1 {
////                        rightArrow.enabled = false
////                    } else {
////                        rightArrow.enabled = true
////                    }
////                    
////                    bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
////                    // Load article in web and zen mode
////                    articleWebView.alpha = 0.0
////                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: bookmarkedFeeds[articleIndex].url!)!))
////                    
////                    //                    if self.bookmarkedFeeds[self.articleIndex].read == false {
////                    self.markRead()
////                    //                    }
////                } else {
////                    
////                    if articleIndex == feeds.count - 1 {
////                        rightArrow.enabled = false
////                    } else {
////                        rightArrow.enabled = true
////                    }
////                    
////                    if feeds[articleIndex].bookmarked == true {
////                        bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
////                    } else {
////                        bookmark.image = UIImage(named: "icon_bookmark")
////                    }
////                    
////                    // Load article in web and zen mode
////                    articleWebView.alpha = 0.0
////                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
////                    
////                    //                    if self.feeds[self.articleIndex].read == false {
////                    self.markRead()
////                    //                    }
////                }
//            }
//        }
//        
    }
    
    func onZenModeBtnPress(sender:UIButton){
        isZenMode = true
        zenModeBtnView.hidden = true
        customSegmentedControl.selectedSegmentIndex = 1
        self.articleWebView.alpha = 0.0
        toolbar.alpha = 1.0
        self.navigationController?.cancelSGProgress()
        self.progressTimer.invalidate()
        self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(articleIndex)
        
        UIView.animateWithDuration(ANIMATION_DURATION, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.zenModeScrollView.alpha = 1.0
            }, completion: nil)
    }


    // Toolbar actions
    func onNext(){
        
        var count = 0
        if isBookmarked == true {
            count = self.bookmarkedFeeds.count
        } else {
            count = self.feeds.count
        }
        
        if articleIndex < count - 1 {
            articleWebView.alpha = 0.0
            zenModeBtnView.hidden = false
            leftArrow.enabled = true
            
            // Load article in web and zen mode
            articleIndex = articleIndex + 1
            
            if isBookmarked == true {
                bookmark.image = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: bookmarkedFeeds[articleIndex].url!)!))
                createProgressBar()
//                if self.bookmarkedFeeds[self.articleIndex].read == false {
                    self.markRead()
//                }
                
                if articleIndex == self.bookmarkedFeeds.count - 1 {
                    rightArrow.enabled = false
                }
                
            } else {
                if feeds[articleIndex].bookmarked == true {
                    bookmark.image = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                } else {
                    bookmark.image = UIImage(named: ICON_BOOKMARK)
                }
                
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                createProgressBar()
//                if self.feeds[self.articleIndex].read == false {
                    self.markRead()
//                }
                
                if articleIndex == self.feeds.count - 1 {
                    rightArrow.enabled = false
                }
            }
            
            self.removeZenWebView(self.articleIndex - 3)
            
            if self.isFromNextORPrev == true {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(self.articleIndex)
                })
            }
            
            self.createZenWebView(self.articleIndex + 2)
        }
    }
    
    func onPrev(){
        
        if articleIndex > 0 {
            articleWebView.alpha = 0.0
            zenModeBtnView.hidden = false
            rightArrow.enabled = true
            
            // Load article in web and zen mode
            articleIndex = articleIndex - 1
            
            if isBookmarked == true {
                bookmark.image = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: bookmarkedFeeds[articleIndex].url!)!))
                
                createProgressBar()
//                if self.bookmarkedFeeds[self.articleIndex].read == false {
                    self.markRead()
//                }
                
            } else {
                if feeds[articleIndex].bookmarked == true {
                    bookmark.image = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                } else {
                    bookmark.image = UIImage(named: ICON_BOOKMARK)
                }
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                
                createProgressBar()
//                if self.feeds[self.articleIndex].read == false {
                    self.markRead()
//                }
            }
            
            self.removeZenWebView(self.articleIndex + 3)
            
            if isFromNextORPrev == true {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(self.articleIndex)
                })
            }
            
            self.createZenWebView(self.articleIndex - 2)
            
        }
        
        if articleIndex == 0 {
            leftArrow.enabled = false
        }
    }
    
    func onBookmark(){
        var articleID : Int;
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            if isBookmarked == true {
                articleID = bookmarkedFeeds[articleIndex].id!
                if self.bookmarkedFeeds[articleIndex].bookmarked == true {
                    self.bookmark.image = UIImage(named: ICON_BOOKMARK)
                    self.bookmarkedFeeds[articleIndex].bookmarked = false
                } else {
                    self.bookmark.image = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                }
            } else {
                articleID = feeds[articleIndex].id!
                if self.feeds[articleIndex].bookmarked == true {
                    self.bookmark.image = UIImage(named: ICON_BOOKMARK)
                    self.feeds[self.articleIndex].bookmarked = false
                } else {
                    self.bookmark.image = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    self.feeds[self.articleIndex].bookmarked = true
                }
            }
            
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            
            let parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "link_id":articleID]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        let message = processedData.objectForKey("message") as! String
                        var bookmarkDictionary = processedData.objectForKey("bookmark") as! [String:AnyObject]
                        let linkID = bookmarkDictionary["link_id"] as! Int
                        if message == "Bookmark Created" {
                            
                            var data : [InformerlyFeed] = []
                            if self.isCategoryFeeds == false && self.isFromFeeds == true {
                                data = Feeds.sharedInstance.getFeeds()
                            } else {
                                data = self.feeds
                            }
                            
                            var counter = 0
                            for feed : InformerlyFeed in data {
                                if feed.id == linkID {
                                    if self.isBookmarked == true {
                                        self.bookmarkedFeeds[self.articleIndex].bookmarked = true
                                        CoreDataManager.addBookmarkFeed(self.bookmarkedFeeds[self.articleIndex], isSynced: true)
                                    } else {
                                        CoreDataManager.addBookmarkFeed(feed, isSynced: true)
                                    }
                                    if self.isCategoryFeeds == false && self.isFromFeeds == true {
                                        Feeds.sharedInstance.getFeeds()[counter].bookmarked = true
                                    } else {
                                        self.feeds[counter].bookmarked = true
                                    }
                                    
                                    break
                                }
                                counter++
                            }
                            
                        } else if message == "Bookmark Removed" {
                            var data : [InformerlyFeed] = []
                            if self.isCategoryFeeds == false {
                                data = Feeds.sharedInstance.getFeeds()
                            }else {
                                data = self.feeds
                            }
                            var counter = 0
                            var isMatched = false
                            for feed : InformerlyFeed in data {
                                if feed.id == linkID {
                                    isMatched = true
                                    CoreDataManager.removeBookmarkFeedOfID(feed.id!)
                                    if self.isCategoryFeeds == false {
                                        Feeds.sharedInstance.getFeeds()[counter].bookmarked = false
                                    } else {
                                        self.feeds[counter].bookmarked = false
                                    }
                                    
                                    if self.isBookmarked == true {
//                                        self.resetZenModeWebView()
                                    }
                                    break
                                }
                                counter++
                            }
                            
                            if isMatched == false {
                                CoreDataManager.removeBookmarkFeedOfID(linkID)
                                if self.isBookmarked == true {
//                                    self.resetZenModeWebView()
                                }
                            }
                        }
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    
                    if extraInfo != nil {
                        var error : [String:AnyObject] = extraInfo as! Dictionary
                        let message : String = error["error"] as! String
                        
                        if message == "Invalid authentication token." {
                            let alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                                self.showViewController(loginVC, sender: self)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                        self.showAlert("Error !", msg: message)
                    }
                }
        } else {
            
            if isBookmarked == true {
                
                if self.bookmarkedFeeds[articleIndex].bookmarked == true {
                    self.bookmark.image = UIImage(named: ICON_BOOKMARK)
                    self.bookmarkedFeeds[articleIndex].bookmarked = false
                    
                    var counter = 0
                    let linkID = self.bookmarkedFeeds[articleIndex].id
                    for feed : InformerlyFeed in self.feeds {
                        if feed.id == linkID {
                            self.feeds[counter].bookmarked = false
                            break
                        }
                        counter++
                    }
                    
                    CoreDataManager.removeBookmarkFeedOfID(bookmarkedFeeds[articleIndex].id!)
                } else {
                    self.bookmark.image = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    self.bookmarkedFeeds[articleIndex].bookmarked = true
                    
                    var counter = 0
                    let linkID = self.bookmarkedFeeds[articleIndex].id
                    for feed : InformerlyFeed in self.feeds {
                        if feed.id == linkID {
                            self.feeds[counter].bookmarked = true
                            break
                        }
                        counter++
                    }
                    
                    CoreDataManager.addBookmarkFeed(bookmarkedFeeds[articleIndex], isSynced: true)
                }
                
//                self.resetZenModeWebView()
            } else {
                if self.feeds[self.articleIndex].bookmarked == true {
                    self.bookmark.image = UIImage(named: ICON_BOOKMARK)
                    self.feeds[self.articleIndex].bookmarked = false
                    bookmarkedFeeds = CoreDataManager.getBookmarkFeeds()
                    CoreDataManager.removeBookmarkFeedOfID(bookmarkedFeeds[articleIndex].id!)
                } else {
                    self.bookmark.image = UIImage(named: ICON_BOOKMARK_FILLED)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    self.feeds[self.articleIndex].bookmarked = true
                    CoreDataManager.addBookmarkFeed(self.feeds[self.articleIndex], isSynced: false)
                }
                
            }
        }
    }
    
//    func resetZenModeWebView() {
//        
//        let subViews = self.zenModeScrollView.subviews
//        for subview in subViews{
//            subview.removeFromSuperview()
//        }
//        
//        self.bookmarkedFeeds = CoreDataManager.getBookmarkFeeds()
//        
//        if self.bookmarkedFeeds.isEmpty {
//            self.onBackPressed()
//        }
//        
//        if self.bookmarkedFeeds.count == 1 {
//            self.leftArrow.enabled = false
//            self.rightArrow.enabled = false
//        }
////        else if self.bookmarkedFeeds.count == 2 {
////            if self.articleIndex + 1 == self.bookmarkedFeeds.count {
////                self.rightArrow.enabled = false
////            }
////        }
//        
//        self.zenModeScrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(self.bookmarkedFeeds.count) , self.view.frame.height)
//        
//        self.zenModeWebViewX = 0
//        for var i=0; i<self.bookmarkedFeeds.count; i++ {
//            // Creates Zen mode Web view
//            var frame : CGRect = CGRectMake(self.zenModeWebViewX, 0, self.view.frame.size.width, self.view.frame.height)
//            var articleZenView : UIWebView = UIWebView()
//            articleZenView.delegate = self
//            articleZenView.frame = frame
//            articleZenView.scrollView.delegate = self
//            self.zenModeScrollView.addSubview(articleZenView)
//            
//            if self.bookmarkedFeeds[i].content != nil {
//                var content : String = self.bookmarkedFeeds[i].content!
//                articleZenView.loadHTMLString(content, baseURL: nil)
//            }
//            
//            self.zenModeWebViewX = self.zenModeWebViewX + self.view.frame.width
//        }
//        
//        if self.articleIndex == self.bookmarkedFeeds.count {
//            self.articleIndex = self.articleIndex - 1
//        } else {
//            self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(self.articleIndex - 1)
//        }
//        
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(self.articleIndex)
//        })
//    }
    
    
    // Zen web view delegate methods
    func webViewDidFinishLoad(webView: UIWebView) {
//        webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitUserSelect='none';")
    }
        
    func showAlert(title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func appDidBecomeActiveCalled(){
        
        if Utilities.sharedInstance.getBoolForKey(IS_FROM_PUSH) == true {
            Utilities.sharedInstance.setBoolForKey(true, key: FROM_PUSH_AND_FROM_ARTICLE_VIEW)
            self.onBackPressed()
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}