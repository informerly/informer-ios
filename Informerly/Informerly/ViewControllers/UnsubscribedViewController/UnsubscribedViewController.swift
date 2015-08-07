//
//  UnsubscribedViewController.swift
//  Informerly
//
//  Created by Apple on 07/08/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit

class UnsubscribedViewController: UIViewController {
    
    @IBOutlet weak var gotoInformerlyBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.applyGradient()
        self.gotoInformerlyBtn.layer.cornerRadius = 8.0
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
    
    @IBAction func onGotoInformerlyPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://informerly.com/")!)
    }
    
    @IBAction func onSignInAgainPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
