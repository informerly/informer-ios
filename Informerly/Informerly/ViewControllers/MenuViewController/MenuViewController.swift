//
//  MenuViewController.swift
//  Informerly
//
//  Created by Apple on 06/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
class MenuViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyGradient()
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
    
    @IBAction func onCrossPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}