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
        self.createSegmentedControl()
        
        articalWebView = UIWebView()
        var statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        var navBarHeight = self.navigationController?.navigationBar.frame.height
        var resultantHeight = statusBarHeight + navBarHeight!
        articalWebView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        self.view.addSubview(articalWebView)
        
        articalZenView = UIWebView()
        articalZenView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height - resultantHeight)
        articalZenView.hidden = true
        self.view.addSubview(articalZenView)
        
        articalWebView.loadRequest(NSURLRequest(URL: NSURL(string: articleData.URL!)!))
        articalZenView.loadHTMLString(articleData.content, baseURL: nil)
        
    }
    
    func createSegmentedControl() {
        var customSegmentedControl = UISegmentedControl (items: ["Web","Zen"])
        customSegmentedControl.frame = CGRectMake(0, 0,150, 30)
        customSegmentedControl.selectedSegmentIndex = 0
        customSegmentedControl.addTarget(self, action: "segmentedValueChanged:", forControlEvents: .ValueChanged)
        
        self.navigationItem.titleView = customSegmentedControl
    }
    
    func segmentedValueChanged(sender:UISegmentedControl!)
    {
        if sender.selectedSegmentIndex == 0 {
            self.articalZenView.hidden = true
            self.articalWebView.hidden = false
        } else if sender.selectedSegmentIndex == 1 {
            self.articalWebView.hidden = true
            self.articalZenView.hidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}