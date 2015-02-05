//
//  Utilities.swift
//  Informerly
//
//  Created by Apple on 04/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
class Utilities {
    
    class var sharedInstance :Utilities {
        struct Singleton {
            static let instance = Utilities()
        }
        
        return Singleton.instance
    }
    
    func setBoolForKey(value:Bool,key:String) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func getBoolForKey(key:String)->Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
    
    func setStringForKey(value:String,key:String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func getStringForKey(key:String)->String {
        return NSUserDefaults.standardUserDefaults().stringForKey(key)!
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, 9999))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
}