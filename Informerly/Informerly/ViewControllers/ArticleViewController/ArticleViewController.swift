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
    var unreadbookmarkedFeeds : [InformerlyFeed]!
    var bookmarkedFeeds : [InformerlyFeed]!
    var isUnreadTab : Bool!
    var isBookmarked : Bool!
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
        
        if isUnreadTab == true && isBookmarked == false {
            self.feeds = unreadFeeds
        } else if isUnreadTab == true && isBookmarked == true {
            self.bookmarkedFeeds = unreadbookmarkedFeeds
        } else if isBookmarked == true {
            self.bookmarkedFeeds = Bookmarks.sharedInstance.getBookmarks()
        }else {
            self.feeds = Feeds.sharedInstance.getFeeds()
        }
        
        // Creates Article web view
        var frame : CGRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
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
            count = self.bookmarkedFeeds.count
            articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: bookmarkedFeeds[articleIndex].URL!)!))
        } else {
            count = self.feeds.count
            articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
        }
        
        // Create Zen mode ScrollView
        var rect : CGRect = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - resultantHeight)
        self.zenModeScrollView = UIScrollView(frame: rect)
        self.zenModeScrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(count) , self.view.frame.height - resultantHeight)
        self.zenModeScrollView.pagingEnabled = true
        self.zenModeScrollView.delegate = self
        self.zenModeScrollView.alpha = 0.0
        self.view.addSubview(self.zenModeScrollView)
        
        self.zenModeWebViewX = 0
        self.readArticles = [Int]()
        
        for var i=0; i<count; i++ {
            // Creates Zen mode Web view
            var frame : CGRect = CGRectMake(self.zenModeWebViewX, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
            var articleZenView : UIWebView = UIWebView()
            articleZenView.delegate = self
            articleZenView.frame = frame
            articleZenView.scrollView.delegate = self
            self.zenModeScrollView.addSubview(articleZenView)
            
            if isBookmarked == true {
                if bookmarkedFeeds[i].content != nil {
                    var content : String = bookmarkedFeeds[i].content!
                    articleZenView.loadHTMLString(content, baseURL: nil)
                    //Calls Read Web-Service
                    if self.bookmarkedFeeds[self.articleIndex].read == false {
                        self.markRead()
                    }
                }
            } else {
                if feeds[i].content != nil {
                    var content : String = feeds[i].content!
                    articleZenView.loadHTMLString(content, baseURL: nil)
                    //Calls Read Web-Service
                    if self.feeds[self.articleIndex].read == false {
                        self.markRead()
                    }
                }
            }
            
            self.zenModeWebViewX = self.zenModeWebViewX + self.view.frame.width
        }
        
        isZenMode = false
        
        // Create Toolbar
        self.createToolBar()
        
    }
    
    // Creates bar button for navbar
    func createNavBarButtons() {
        var back_btn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onBackPressed"))
        
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
        var zenModeBtnViewRect : CGRect = CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2-110,
            200, 100)
        self.zenModeBtnView = UIView(frame: zenModeBtnViewRect)
        self.view.addSubview(zenModeBtnView)
        
        var zenCloudImageView : UIImageView = UIImageView(image: UIImage(named: "zen_cloud"))
        zenCloudImageView.frame = CGRectMake(zenModeBtnView.frame.size.width/2 - zenCloudImageView.frame.size.width/2,
            0, zenCloudImageView.frame.size.width, zenCloudImageView.frame.size.height)
        zenModeBtnView.addSubview(zenCloudImageView)
        
        var zenModeBtn : UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        zenModeBtn.setImage(UIImage(named: "zen_btn"), forState: UIControlState.Normal)
        zenModeBtn.frame = CGRectMake(zenModeBtnView.frame.size.width/2 - 85,zenCloudImageView.frame.size.height + 10, 170,55)
        zenModeBtn.addTarget(self, action: Selector("onZenModeBtnPress:"), forControlEvents: UIControlEvents.TouchUpInside)
        zenModeBtnView.addSubview(zenModeBtn)
        
//        var zenModeViewLabelRect : CGRect = CGRectMake(0, 150, 200, 45)
//        var zenModeViewLabel : UILabel = UILabel(frame: zenModeViewLabelRect)
//        zenModeViewLabel.numberOfLines = 2
//        zenModeViewLabel.textAlignment = NSTextAlignment.Center
//        zenModeViewLabel.font = UIFont.systemFontOfSize(14.0)
//        zenModeViewLabel.text = "Tap on this button if your connection is slow."
//        zenModeViewLabel.textColor = UIColor.grayColor()
//        zenModeBtnView.addSubview(zenModeViewLabel)
    }
    
    func createProgressBar(){
        
        if self.progressTimer != nil {
            self.progressTimer.invalidate()
        }
        
        self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("progressWithPercentage"), userInfo: nil, repeats: true)
    }
    
    func progressWithPercentage() {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            var percentage : Float = Float(self.articleWebView.estimatedProgress)
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
        
        var flexibleItem1 : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        rightArrow = UIBarButtonItem(image: UIImage(named: "icon_right_arrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onNext"))
        
        var flexibleItem2 : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)

        var img : UIImage? = UIImage(named: "icon_bookmark")
        
        if isBookmarked == true {
            img = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            if articleIndex + 1 == self.bookmarkedFeeds.count {
                rightArrow.enabled = false
            }
        } else {
            if feeds[articleIndex].bookmarked == true {
                img = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            }
            
            if articleIndex + 1 == self.feeds.count {
                rightArrow.enabled = false
            }
        }
        
        bookmark = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onBookmark"))
        
        var flexibleItem3 : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)

        var share : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "share_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onSharePressed"))
        
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
        
        var parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
            "client_id":"",
            "link_id": articleID]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                println("Successfully marked as read.")
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                println("Failure marking article as read")
                
                var readArticles:[Int]!
                if NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) == nil {
                    readArticles = [Int]()
                } else {
                    readArticles = NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) as! Array
                }
                readArticles.append(self.feeds[self.articleIndex].id!)
                NSUserDefaults.standardUserDefaults().setObject(readArticles, forKey: READ_ARTICLES)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                if extraInfo != nil {
                    var error : [String:AnyObject] = extraInfo as! Dictionary
                    var message : String = error["error"] as! String
                    
                    if message == "Invalid authentication token." {
                        var alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
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
        
        if isBookmarked == true {
            sharingItems.append(bookmarkedFeeds[articleIndex].title!)
            sharingItems.append(bookmarkedFeeds[articleIndex].URL!)
        } else {
            sharingItems.append(feeds[articleIndex].title!)
            sharingItems.append(feeds[articleIndex].URL!)
        }
        
        let activityVC = UIActivityViewController(activityItems:sharingItems, applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // Web view delegate
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        println("finish")
        self.zenModeBtnView.hidden = true
        articleWebView.alpha = 1.0
        toolbar.alpha = 1.0
    }
    
    
    // UIScrollView Delegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if isZenMode == true {
            
            if lastContentOffsetX < scrollView.contentOffset.x || lastContentOffsetX > scrollView.contentOffset.x  {
                var pageWidth : CGFloat = self.view.frame.width
                var page : CGFloat = scrollView.contentOffset.x / pageWidth
                articleIndex = Int(page)
                
                if articleIndex == 0 {
                    leftArrow.enabled = false
                } else {
                    leftArrow.enabled = true
                }
                
                
                if isBookmarked == true {
                    
                    if articleIndex == bookmarkedFeeds.count - 1 {
                        rightArrow.enabled = false
                    } else {
                        rightArrow.enabled = true
                    }
                    
                    bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    // Load article in web and zen mode
                    articleWebView.alpha = 0.0
                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: bookmarkedFeeds[articleIndex].URL!)!))
                    
                    if self.bookmarkedFeeds[self.articleIndex].read == false {
                        self.markRead()
                    }
                } else {
                    
                    if articleIndex == feeds.count - 1 {
                        rightArrow.enabled = false
                    } else {
                        rightArrow.enabled = true
                    }
                    
                    if feeds[articleIndex].bookmarked == true {
                        bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    } else {
                        bookmark.image = UIImage(named: "icon_bookmark")
                    }
                    
                    // Load article in web and zen mode
                    articleWebView.alpha = 0.0
                    articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                    
                    if self.feeds[self.articleIndex].read == false {
                        self.markRead()
                    }
                }
            }
        }
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
        
        if articleIndex < self.feeds.count - 1 {
            articleWebView.alpha = 0.0
            zenModeBtnView.hidden = false
            leftArrow.enabled = true
            
            // Load article in web and zen mode
            articleIndex = articleIndex + 1
            
            if isBookmarked == true {
                bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: bookmarkedFeeds[articleIndex].URL!)!))
                createProgressBar()
                if self.bookmarkedFeeds[self.articleIndex].read == false {
                    self.markRead()
                }
                
                if articleIndex == self.bookmarkedFeeds.count - 1 {
                    rightArrow.enabled = false
                }
                
            } else {
                if feeds[articleIndex].bookmarked == true {
                    bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                } else {
                    bookmark.image = UIImage(named: "icon_bookmark")
                }
                
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                createProgressBar()
                if self.feeds[self.articleIndex].read == false {
                    self.markRead()
                }
                
                if articleIndex == self.feeds.count - 1 {
                    rightArrow.enabled = false
                }
            }
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(self.articleIndex)
            })
            
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
               bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: bookmarkedFeeds[articleIndex].URL!)!))
                
                createProgressBar()
                if self.bookmarkedFeeds[self.articleIndex].read == false {
                    self.markRead()
                }
                
            } else {
                if feeds[articleIndex].bookmarked == true {
                    bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                } else {
                    bookmark.image = UIImage(named: "icon_bookmark")
                }
                articleWebView.loadRequest(NSURLRequest(URL: NSURL(string: feeds[articleIndex].URL!)!))
                
                createProgressBar()
                if self.feeds[self.articleIndex].read == false {
                    self.markRead()
                }
            }
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.zenModeScrollView.contentOffset.x = self.view.frame.width * CGFloat(self.articleIndex)
            })
            
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
                    self.bookmark.image = UIImage(named: "icon_bookmark")
                    self.bookmarkedFeeds[self.articleIndex].bookmarked = false
                } else {
                    self.bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    self.bookmarkedFeeds[self.articleIndex].bookmarked = true
                }
            } else {
                articleID = feeds[articleIndex].id!
                if self.feeds[articleIndex].bookmarked == true {
                    self.bookmark.image = UIImage(named: "icon_bookmark")
                    self.feeds[self.articleIndex].bookmarked = false
                } else {
                    self.bookmark.image = UIImage(named: "icon_bookmark_filled")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    self.feeds[self.articleIndex].bookmarked = true
                }
            }
            
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            
            var parameters : [String:AnyObject] = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "link_id":articleID]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    
                    if requestStatus == 200 {
                        var message = processedData["message"] as! String
                        var bookmarkDictionary : [String:AnyObject] = processedData["bookmark"] as! Dictionary
                        var linkID = bookmarkDictionary["link_id"] as! Int
                        if message == "Bookmark Created" {
                            var data : [InformerlyFeed] = Feeds.sharedInstance.getFeeds()
                            var feed : InformerlyFeed
                            var counter = 0
                            for feed in data {
                                if feed.id == linkID {
                                    Feeds.sharedInstance.getFeeds()[counter].bookmarked = true
                                    Bookmarks.sharedInstance.addBookmark(feed)
                                    break
                                }
                                counter++
                            }
                            
                        } else if message == "Bookmark Removed" {
                            var data : [InformerlyFeed] = Feeds.sharedInstance.getFeeds()
                            var feed : InformerlyFeed
                            var counter = 0
                            for feed in data {
                                if feed.id == linkID {
                                    Feeds.sharedInstance.getFeeds()[counter].bookmarked = false
                                    Bookmarks.sharedInstance.removeBookmark(linkID)
                                    break
                                }
                                counter++
                            }
                        }
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    
                    if extraInfo != nil {
                        var error : [String:AnyObject] = extraInfo as! Dictionary
                        var message : String = error["error"] as! String
                        
                        if message == "Invalid authentication token." {
                            var alert = UIAlertController(title: "Error !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                                self.showViewController(loginVC, sender: self)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                        self.showAlert("Error !", msg: message)
                    } else {
                        self.showAlert("Error !", msg: "Try Again!")
                    }
                }
        } else {
            self.showAlert("No Internet !", msg: "You are not connected to internet, Please check your connection.")
        }
    }
    
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
    
    
    // Zen web view delegate methods
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitUserSelect='none';")
    }
        
    func showAlert(title:String, msg:String){
        var alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}