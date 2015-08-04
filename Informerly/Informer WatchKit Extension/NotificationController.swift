//
//  NotificationController.swift
//  Informer WatchKit Extension
//
//  Created by Apple on 30/07/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import WatchKit
import Foundation


class NotificationController: WKUserNotificationInterfaceController {

    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    
    var link_id : Int!
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    /*
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }
    */
    
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        
        var apsDict : NSDictionary = remoteNotification["aps"] as! NSDictionary
        var titleStr : String = apsDict["alert"] as! String
        self.titleLabel.setText(titleStr)
        
        completionHandler(.Custom)
    }

}
