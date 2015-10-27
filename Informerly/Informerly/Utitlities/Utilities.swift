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
    
    func setIntForKey(value:Int,key:String) {
        NSUserDefaults.standardUserDefaults().setInteger(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getIntForKey(key:String)->Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(key)
    }
    
    func setStringForKey(value:String,key:String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getStringForKey(key:String)->String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(key)
    }
    
    func setObjectForKey(object:AnyObject,key:String) {
        NSUserDefaults.standardUserDefaults().setObject(object, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getObjectForKey(key:String)->[Int]? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key) as? [Int]
    }
    
    func setArrayForKey(object:AnyObject,key:String) {
        NSUserDefaults.standardUserDefaults().setObject(object, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getArrayForKey(key:String)->AnyObject {
        
        let data =  NSUserDefaults.standardUserDefaults().objectForKey(key) as! NSData
        let unarchivedData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        return unarchivedData!
    }
    
    // App Group Utilities
    func setAuthToken(value:String,key:String) {
        let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
        userDefaults.setObject(value, forKey: AUTH_TOKEN)
        userDefaults.synchronize()
    }
    
    func getAuthToken(key:String)->String {
        let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
        return userDefaults.stringForKey(key)!
    }
    
    func setBoolAppGroupForKey(value:Bool,key:String) {
        let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
        userDefaults.setBool(value, forKey: key)
        userDefaults.synchronize()
    }
    
    func getBoolForAppGroupKey(key:String)->Bool {
        let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
        return userDefaults.boolForKey(key)
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}