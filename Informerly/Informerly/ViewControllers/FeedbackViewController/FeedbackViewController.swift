//
//  FeedbackViewController.swift
//  Informerly
//
//  Created by Apple on 13/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class FeedbackViewContoller: UIViewController,UITextViewDelegate {
    
    
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var feedbackView: UIView!
    private var indicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        //Apply Gradient
        self.applyGradient()
        self.setCornerRadius()
        
        self.backBtn.tintColor = UIColor.whiteColor()
        self.feedbackTextView.tintColor = UIColor.whiteColor()
        self.feedbackTextView.delegate = self
        
        // Activity indicator
        indicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2 - 25,self.view.frame.height/2 - 25, 50, 50)) as UIActivityIndicatorView
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        view.addSubview(indicator)
    }
    
    func applyGradient() {
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        
        let lightBlueColor = UIColor(rgba : LIGHT_BLUE_COLOR).CGColor
        let darkBlueColor = UIColor(rgba : DARK_BLUE_COLOR).CGColor
        let arrayColors = [lightBlueColor, darkBlueColor]
        
        gradient.colors = arrayColors
        view.layer.insertSublayer(gradient, atIndex: 0)
        
    }
    
    func setCornerRadius() {
        self.feedbackTextView.layer.cornerRadius = 8.0
        self.feedbackTextView.layer.borderWidth = 1.0
        self.feedbackTextView.layer.borderColor = UIColor(rgba: BORDER_COLOR).CGColor
        
        self.sendbtn.layer.cornerRadius = 8.0
        self.sendbtn.layer.borderWidth = 1.0
        self.sendbtn.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    @IBAction func onSendBtnPress(sender: AnyObject) {
        self.view.endEditing(true)
        self.sendbtn.enabled = false
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            if (self.feedbackTextView.text != "Bugs, comments or feature ideas?" &&
                self.feedbackTextView.text != "")
            {
                indicator.startAnimating()
                let feedback : PFObject = PFObject(className: "Feedback")
                feedback["feedback"] = self.feedbackTextView.text
                feedback["email"] = Utilities.sharedInstance.getStringForKey(EMAIL)
                feedback["userID"] = Utilities.sharedInstance.getStringForKey(USER_ID)
                feedback.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if (success) {
                        self.indicator.stopAnimating()
                        self.backBtn.hidden = true
                        self.feedbackLabel.hidden = true
                        self.feedbackView.hidden = true
                        
                        let rect : CGRect = CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/3, 110, 40)
                        let thanksLabel : UILabel = UILabel(frame:rect)
                        thanksLabel.font = UIFont(name: "OpenSans-Bold", size: 28)
                        thanksLabel.text = "Thanks!"
                        thanksLabel.textColor = UIColor.whiteColor()
                        self.view.addSubview(thanksLabel)
                        
                        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("animateView"), userInfo: nil, repeats: false)
                        
                    } else {
                        self.indicator.stopAnimating()
                        self.showAlert("Error !", msg: "Unable to save feedback. Please try again")
                    }
                })
            } else {
                self.showAlert("No Feedback !", msg: "Please add some feedback.")
            }
        } else {
            self.showAlert("No Signal?  Don't worry!", msg: "You can still read your Saved Articles from the side menu.")
        }
    }
    
    @IBAction func onBackBtnPress(sender: AnyObject) {
//        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // UITextViewDelegates
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.text == "Bugs, comments or feature ideas?" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        textView.resignFirstResponder()
        if textView.text == "" {
            textView.text = "Bugs, comments or feature ideas?"
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showAlert(title:String, msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func animateView() {
//        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}