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
}