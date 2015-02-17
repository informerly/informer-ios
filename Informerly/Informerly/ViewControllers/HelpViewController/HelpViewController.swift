//
//  HelpViewController.swift
//  Informerly
//
//  Created by Apple on 13/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
import MessageUI

class HelpViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var helpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        // Apply Gradient
        self.applyGradient()
        self.setCornerRadius()
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
        self.helpView.layer.cornerRadius = 8.0
        self.helpView.layer.borderWidth = 1.0
        self.helpView.layer.borderColor = UIColor(rgba: BORDER_COLOR).CGColor
    }
    
    @IBAction func onBackPress(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onSupportBtnPress(sender: AnyObject) {
        
        var emailTitle = "iOS Support: \(Utilities.sharedInstance.getStringForKey(USER_ID))"
        var toRecipents = ["support@informerly.com"]
        
        var mailComposer: MFMailComposeViewController = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject(emailTitle)
        mailComposer.setToRecipients(toRecipents)
        
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}