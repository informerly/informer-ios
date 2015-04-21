//
//  UpdateInterestViewController.swift
//  Informerly
//
//  Created by Apple on 21/04/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class UpdateInterestViewController : UIViewController {
    
    @IBOutlet weak var interestsTextView: UITextView!
    var textViewFrame : CGRect!
    var indicator : UIActivityIndicatorView!
    var overlay : UIView!
    var alert : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Nav bar.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.translucent = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        self.createNavTitle()
        self.createNavBarButtons()
        self.createOverlayView()
        
        textViewFrame = self.interestsTextView.frame
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func createNavTitle() {

        var navTitle : UILabel = UILabel(frame: CGRectMake(0, 0, 80, 30))
        navTitle.text = "Update Your Interests"
        navTitle.font = UIFont(name: "OpenSans-Regular", size: 14.0)
        
        self.navigationItem.titleView = navTitle
    }
    
    // Creates bar button for navbar
    func createNavBarButtons() {
        var back_btn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onBackPress"))
        back_btn.tintColor = UIColor.grayColor()
        self.navigationItem.leftBarButtonItem = back_btn
        
        var send_btn : UIBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onSendPress"))
        self.navigationItem.rightBarButtonItem = send_btn
    }
    
    func createOverlayView(){
        overlay = UIView(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: self.view.frame.height))
        overlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        overlay.hidden = true
        self.view.addSubview(overlay)
        
        // Activity indicator
        indicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height/2 - 25, 0, 0)) as UIActivityIndicatorView
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        overlay.addSubview(indicator)
        
        // Creates alert view
        var rect:CGRect = CGRectMake((self.view.frame.size.width - 280)/2, (self.view.frame.size.height - 280 - 64)/2, 280, 280)
        alert = UIView(frame: rect)
        alert.hidden = true
        alert.backgroundColor = UIColor.whiteColor()
        overlay.addSubview(alert)
        
        // Adds button
        var okBtn : UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        okBtn.frame = CGRectMake(0,230,280,50)
        okBtn.backgroundColor = UIColor(rgba: "#3592FF")
        okBtn.setTitle("OK", forState: UIControlState.Normal)
        okBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        okBtn.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 15)
        okBtn.addTarget(self, action: Selector("onOKPress"), forControlEvents: UIControlEvents.TouchUpInside)
        alert.addSubview(okBtn)
    }
    
    func onBackPress(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onSendPress(){
        self.view.endEditing(true)
        self.overlay.hidden = false
        var timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("showAlert"), userInfo: nil, repeats: false)
    }
    
    func showAlert(){
        self.alert.hidden = false
    }
    
    func onOKPress(){
        alert.hidden = true
        overlay.hidden = true
    }
    
    // Keyboard notifications
    func keyboardWillShow() {
        
        if (self.view.frame.size.height <= 480) {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.frame = CGRectMake(0, -30, self.view.frame.width, self.view.frame.height)
            })
            self.interestsTextView.frame = CGRectMake(self.interestsTextView.frame.origin.x, self.interestsTextView.frame.origin.y, self.interestsTextView.frame.size.width, 150)
        } else if (self.view.frame.size.height <= 568) {
            self.interestsTextView.frame = CGRectMake(self.interestsTextView.frame.origin.x, self.interestsTextView.frame.origin.y, self.interestsTextView.frame.size.width, 150)
        }
        else if (self.view.frame.size.height > 568) {
            self.interestsTextView.frame = CGRectMake(self.interestsTextView.frame.origin.x, self.interestsTextView.frame.origin.y, self.interestsTextView.frame.size.width, 220)
        }
    }
    
    func keyboardWillHide() {
        self.interestsTextView.frame = textViewFrame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}