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
    
    
    func setAuthToken(value:String,key:String) {
        var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.Informerly.informerWidget")!
        userDefaults.setObject(value, forKey: AUTH_TOKEN)
        userDefaults.synchronize()
    }
    
    func getAuthToken(key:String)->String {
        var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.Informerly.informerWidget")!
        return userDefaults.stringForKey(key)!
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
    
}