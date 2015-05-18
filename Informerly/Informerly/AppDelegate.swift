//
//  AppDelegate.swift
//  Informerly
//
//  Created by Apple on 02/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var reachability:Reachability?;
    var readArticles : [Int]!
 
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        // Adds crittercism sdk for crash logs
//        Crittercism.enableWithAppID("553120c07365f84f7d3d6e79")
        
        if UIDevice.currentDevice().model == "iPhone Simulator" {
            Utilities.sharedInstance.setStringForKey("", key: DEVICE_TOKEN)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForReachability:", name: kReachabilityChangedNotification, object: nil);
        
        self.reachability = Reachability.reachabilityForInternetConnection();
        self.reachability?.startNotifier()
        
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                if let linkID = notification["link_id"] as? NSNumber {
                    Utilities.sharedInstance.setStringForKey(linkID.stringValue, key: LINK_ID)
                }
                else {
                    Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
                }
            }
            else if let url = options[UIApplicationLaunchOptionsURLKey] as? NSURL {
                Utilities.sharedInstance.setStringForKey(url.lastPathComponent!, key: LINK_ID)
            } else {
                var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.Informerly.informerWidget")!
                var linkID : String = userDefaults.stringForKey("id")!
                Utilities.sharedInstance.setStringForKey(linkID, key: LINK_ID)
            }
            
        }
        else {
            Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
        }
        
        // Emily adding Parse details - for Junaid's review.
        
        // Enable Crash Reporting
//        ParseCrashReporting.enable()
        
        // Setup Parse
        Parse.setApplicationId("cZuNXGv2vSezrMNI2aHniKwxn2SStYJjOVQCwtgG", clientKey: "unn7iH2MUeB5G9IErfiYSp5q1KWIc3SbiuFnJa4t")
        
        // Setup Parse Push/Open Tracking
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced
            // in iOS 7). In that case, we skip tracking here to avoid double
            // counting the app-open.
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
            }
        }
        
        var pushSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        
        application.applicationIconBadgeNumber = 0
        var setting : UIUserNotificationSettings = UIUserNotificationSettings(forTypes:
            UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound,
            categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(setting);
        UIApplication.sharedApplication().registerForRemoteNotifications();
        
        
        if Utilities.sharedInstance.getBoolForKey(IS_USER_LOGGED_IN) {
            self.loadFeedVC()
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
  
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }

    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Send parsed token to Rails via API
        var token : String = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        println(token)
        Utilities.sharedInstance.setStringForKey(token, key: DEVICE_TOKEN)
        
        // Send deviceToken to Parse
        var currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.save()
        println("Success")
    }
  
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        println("app recieved notification from remote \(userInfo)");
        
        if Utilities.sharedInstance.getBoolForKey(IS_USER_LOGGED_IN) {
            
            var linkID : String = String(userInfo["link_id"] as! Int)
            Utilities.sharedInstance.setStringForKey(linkID, key: LINK_ID)
            
            self.loadFeedVC()
        }
        

        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: nil)
        }
        println("Push sent/opened?")
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        if url.scheme == "TodayExtension" {
            var userDefaults : NSUserDefaults = NSUserDefaults(suiteName: "group.com.Informerly.informerWidget")!
            var linkID : String = userDefaults.stringForKey("id")!
            Utilities.sharedInstance.setStringForKey(linkID, key: LINK_ID)
            println(linkID)
            self.loadFeedVC()
        } else if url.scheme == "informerly" {
            Utilities.sharedInstance.setStringForKey(url.lastPathComponent!, key: LINK_ID)
            Utilities.sharedInstance.setBoolForKey(true, key: IS_FROM_CUSTOM_URL)
            self.loadFeedVC()
        }
        
        return true
    }
    
    
    func checkForReachability(notification:NSNotification)
    {
        let networkReachability = notification.object as! Reachability;
        var remoteHostStatus = networkReachability.currentReachabilityStatus()
        
        if (remoteHostStatus.value == NotReachable.value)
        {
            println("Not Reachable")
        }
        else
        {
            println("Reachable")
            
            if Utilities.sharedInstance.getBoolForKey(IS_USER_LOGGED_IN) {
                
                if (NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) != nil) {
                    self.readArticles = NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) as! Array
                    
                    if (readArticles != nil) && (readArticles?.isEmpty == false) {
                        self.markUnreadArticles(readArticles!)
                    }
                }
                
                var unbookmarkedFeeds:[BookmarkFeed] = CoreDataManager.getBookmarkFeeds()
                
                for feed in unbookmarkedFeeds {
                    if feed.isSynced == false {
                        self.markBookmarked(feed.id!.integerValue)
                    }
                }
            }
        }
    }
    
    
    func markUnreadArticles(articlesList : [Int]){
        
        for articleID in articlesList {
            self.markRead(articleID)
        }
    }
    
    func markRead(articleID:Int) {
        var path : String = "links/\(articleID)/read"
        var parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
            "client_id":"",
            "link_id": articleID]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                println("Successfully marked as read.")
                
                self.readArticles.removeAtIndex(find(self.readArticles, articleID)!)
                NSUserDefaults.standardUserDefaults().setObject(self.readArticles, forKey: READ_ARTICLES)
                NSUserDefaults.standardUserDefaults().synchronize()
                
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                println("Failure marking article as read")
        }
    }
    
    func markBookmarked(feedID:Int){
        var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
        
        var parameters : [String:AnyObject] = ["auth_token":auth_token,
            "client_id":"dev-ios-informer",
            "link_id":feedID]
        
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                
                if requestStatus == 200 {
                    var bookmarkDictionary : [String:AnyObject] = processedData["bookmark"] as! Dictionary
                    var linkID = bookmarkDictionary["link_id"] as! Int
                    CoreDataManager.updateSyncStatusForFeedID(linkID, syncStatus: true)
                    println("Marked ...")
                }
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                println("Failed to bookmark ...")
        }
    }
    
    func loadFeedVC(){
        var storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        var container = storyboard.instantiateViewControllerWithIdentifier("MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
        
        var leftSideMenuViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("LeftMenuViewController") as! UIViewController
        
        var rootVC = storyboard.instantiateViewControllerWithIdentifier("FeedVC") as! FeedViewController
        var navigationVC: UINavigationController = UINavigationController(rootViewController: rootVC)
        
        container.panMode = MFSideMenuPanModeSideMenu
        container.leftMenuViewController = leftSideMenuViewController
        container.rightMenuViewController = nil
        container.centerViewController = navigationVC
        
        self.window?.rootViewController = container
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mycompany.test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Informer", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Informer.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

    
}