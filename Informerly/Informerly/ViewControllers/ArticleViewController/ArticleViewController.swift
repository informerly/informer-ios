//
//  File.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class ArticleViewController : UIViewController {
    
    var articalWebView : UIWebView!
    var articalZenView : UIWebView!
    var articleData : Feeds.InformerlyFeed!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.hidesBackButton = true
        self.createNavBarButtons()
        self.createSegmentedControl()
        
        articalWebView = UIWebView()
        var statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        var navBarHeight = self.navigationController?.navigationBar.frame.height
        var resultantHeight = statusBarHeight + navBarHeight!
        articalWebView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articalWebView.scalesPageToFit = true
        self.view.addSubview(articalWebView)
        
        articalZenView = UIWebView()
        articalZenView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articalZenView.hidden = true
        self.view.addSubview(articalZenView)
        
        articalWebView.loadRequest(NSURLRequest(URL: NSURL(string: articleData.URL!)!))
        articalZenView.loadHTMLString(articleData.content, baseURL: nil)
        
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
            self.articalZenView.hidden = true
            self.articalWebView.hidden = false
            
            self.articalWebView.frame = CGRectMake(-self.articalWebView.frame.width*2,
                self.articalWebView.frame.origin.y,
                self.articalWebView.frame.size.width, self.articalWebView.frame.size.height)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.articalWebView.frame = CGRectMake(0,
                    self.articalWebView.frame.origin.y,
                    self.articalWebView.frame.size.width, self.articalWebView.frame.size.height)
            })
            
            
        } else if sender.selectedSegmentIndex == 1 {
            
            self.articalWebView.hidden = true
            self.articalZenView.hidden = false
            
            self.articalZenView.frame = CGRectMake(self.articalZenView.frame.width*2,
                self.articalZenView.frame.origin.y,
                self.articalZenView.frame.size.width, self.articalZenView.frame.size.height)
            
            UIView.animateWithDuration(0.40, animations: { () -> Void in
                self.articalZenView.frame = CGRectMake(0,
                    self.articalZenView.frame.origin.y,
                    self.articalZenView.frame.size.width, self.articalZenView.frame.size.height)
            })
        }
    }
    
    func onBackPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onSharePressed() {
        var sharingItems = [AnyObject]()
        sharingItems.append(articleData.title!)
        sharingItems.append(articleData.URL!)
        
        let activityVC = UIActivityViewController(activityItems:sharingItems, applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}