//
//  UpdateInterestViewController.swift
//  Informerly
//
//  Created by Apple on 21/04/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class UpdateInterestViewController : UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var interestsTextView: UITextView!
    var textViewFrame : CGRect!
    var indicator : UIActivityIndicatorView!
    var overlay : UIView!
    var alert : UIView!
    var send_btn : UIBarButtonItem!
    var back_btn : UIBarButtonItem!
    
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
        
        self.interestsTextView.delegate = self
        self.interestsTextView.becomeFirstResponder()
        
        textViewFrame = self.interestsTextView.frame
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func createNavTitle() {

        var navTitle : UILabel = UILabel(frame: CGRectMake(0, 0, 80, 30))
        navTitle.text = "Update Your Interests"
        navTitle.font = UIFont(name: "OpenSans", size: 16.0)
        
        self.navigationItem.titleView = navTitle
    }
    
    // Creates bar button for navbar
    func createNavBarButtons() {
        back_btn = UIBarButtonItem(image: UIImage(named: "back_btn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onBackPress"))
        back_btn.tintColor = UIColor.grayColor()
        self.navigationItem.leftBarButtonItem = back_btn
        
        send_btn = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onSendPress"))
        send_btn.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "OpenSans", size: 16.0)!], forState: UIControlState.Normal)
        send_btn.enabled = false
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
        var rect:CGRect = CGRectMake((self.view.frame.size.width - 280)/2, (self.view.frame.size.height - 280 - 64)/2, 280, 230)
        alert = UIView(frame: rect)
        alert.hidden = true
        alert.layer.cornerRadius = 5.0
        alert.backgroundColor = UIColor.whiteColor()
        overlay.addSubview(alert)
        
        // Check cirle image view
        var imageViewRect = CGRectMake((alert.frame.size.width - 36)/2, 20, 36, 36)
        var checkCirleImgView : UIImageView = UIImageView(frame: imageViewRect)
        checkCirleImgView.image = UIImage(named: "icon_check_circle")
        alert.addSubview(checkCirleImgView)
        
        // Updated Interests label
        var updatedInterestLabelRect = CGRectMake((alert.frame.size.width - 220)/2, 20+36, 220, 40)
        var updatedInterestLabel : UILabel = UILabel(frame: updatedInterestLabelRect)
        updatedInterestLabel.text = "Updated Interests Sent!"
        updatedInterestLabel.font = UIFont(name: "OpenSans-Bold", size: 18.0)
        updatedInterestLabel.textColor = UIColor(rgba: "#3592FF")
        alert.addSubview(updatedInterestLabel)
        
        // sub label
        var subLabelRect = CGRectMake((alert.frame.size.width - 280)/2, 20+36+40+5, 280, 60)
        var subLabel : UILabel = UILabel(frame: subLabelRect)
        subLabel.numberOfLines = 3
        subLabel.textAlignment = NSTextAlignment.Center
        subLabel.text = "One of our team members will personally tailor your news feed to include your new interests."
        subLabel.font = UIFont(name: "OpenSans", size: 13.0)
        alert.addSubview(subLabel)
        
        
        // Adds button
        var okBtn : UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        okBtn.frame = CGRectMake(0,180,280,50)
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
        self.send_btn.enabled = false
        self.back_btn.enabled = false
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            if (self.interestsTextView.text != "") {
                var interests : PFObject = PFObject(className: "Interests")
                interests["interest"] = self.interestsTextView.text
                interests["email"] = Utilities.sharedInstance.getStringForKey(EMAIL)
                interests["userID"] = Utilities.sharedInstance.getStringForKey(USER_ID)
                interests.saveInBackgroundWithBlock { (success:Bool, error:NSError!) -> Void in
                    if (success) {
                        self.alert.hidden = false
                    } else {
                        self.showAlert("Error !", msg: "Unable to save feedback. Please try again")
                    }
                }
            }
        } else {
            self.showAlert("Looks like you have no signal.", msg: "Don't worry! You can still read your Saved Articles from the side menu.")
            overlay.hidden = true
        }
    }
    
    func onOKPress(){
        alert.hidden = true
        overlay.hidden = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // TextView delegates methods
    func textViewDidChange(textView: UITextView) {
        if textView.text == "" {
            send_btn.enabled = false
        } else {
            send_btn.enabled = true
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
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
    
    func showAlert(title:String, msg:String) {
        var alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}