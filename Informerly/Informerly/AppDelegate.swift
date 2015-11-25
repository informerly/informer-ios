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
    private var reachability:Reachability?
    var readArticles : [Int]!
 
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        if IS_DEV_ENV {
            Mixpanel.sharedInstanceWithToken(MIXPANEL_DEV_TOKEN)
        } else {
            Mixpanel.sharedInstanceWithToken(MIXPANEL_PROD_TOKEN)
        }
        
        let appCount = Utilities.sharedInstance.getIntForKey(LAUNCH_COUNT)
        if (appCount == 0) {
            Utilities.sharedInstance.setIntForKey(appCount + 1, key: LAUNCH_COUNT)
            Utilities.sharedInstance.setStringForKey(appVersion, key: APP_VERSION)
            Mixpanel.sharedInstance().track("App Download")
        } else {
            Mixpanel.sharedInstance().track("App Launch")
        }
        
        if (appVersion != Utilities.sharedInstance.getStringForKey(APP_VERSION)) {
            Mixpanel.sharedInstance().track("App Update")
        }
        
        // Adds crittercism sdk for crash logs
        Crittercism.enableWithAppID("553120c07365f84f7d3d6e79")
        
        if UIDevice.currentDevice().model == "iPhone Simulator" {
            Utilities.sharedInstance.setStringForKey("", key: DEVICE_TOKEN)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForReachability:", name: kReachabilityChangedNotification, object: nil);
        
        self.reachability = Reachability.reachabilityForInternetConnection();
        self.reachability?.startNotifier()
        
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {

                //Mixpanel track
                Mixpanel.sharedInstance().track("Notification - Click")

                if let linkID = notification["link_id"] as? NSNumber {
                    Utilities.sharedInstance.setStringForKey(linkID.stringValue, key: LINK_ID)
                }
                else {
                    Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
                }

                if let feedID = notification["feed_id"] as? NSNumber {
                    Utilities.sharedInstance.setStringForKey(feedID.stringValue, key: FEED_ID)
                } else {
                    Utilities.sharedInstance.setStringForKey("-1", key: FEED_ID)
                }
            }
//            else if let url = options[UIApplicationLaunchOptionsURLKey] as? NSURL {
//                Utilities.sharedInstance.setStringForKey(url.lastPathComponent!, key: LINK_ID)
//            }
            else {
                let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
                let linkID = userDefaults.stringForKey("id")
                if linkID != nil {
                    Utilities.sharedInstance.setStringForKey(linkID!, key: LINK_ID)
                }
            }
            
        }
        else {
            Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
            Utilities.sharedInstance.setStringForKey("-1", key: FEED_ID)
        }
    
        // Emily adding Parse details - for Junaid's review.
        
        // Enable Crash Reporting
        ParseCrashReporting.enable()
        
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
        print(token)
        Utilities.sharedInstance.setStringForKey(token, key: DEVICE_TOKEN)
        
        // Send deviceToken to Parse
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        
        currentInstallation.saveInBackground()
        print("Success")
    }
  
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        PFPush.handlePush(userInfo)
        
        if Utilities.sharedInstance.getBoolForKey(IS_USER_LOGGED_IN) {
            
            //Mixpanel track
            Mixpanel.sharedInstance().track("Notification - Click")
            
            if userInfo["link_id"] != nil {
                let linkID : String = String(userInfo["link_id"] as! Int)
                Utilities.sharedInstance.setStringForKey(linkID, key: LINK_ID)
            } else {
                Utilities.sharedInstance.setStringForKey("-1", key: LINK_ID)
            }
            
            if userInfo["feed_id"] != nil {
                let feedID = String(userInfo["feed_id"] as! Int)
                Utilities.sharedInstance.setStringForKey(feedID, key: FEED_ID)
            }
            
            Utilities.sharedInstance.setBoolForKey(true, key: IS_FROM_PUSH)
        }
        

        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: nil)
        }
        print("Push sent/opened?")
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme == "TodayExtension" {
            Utilities.sharedInstance.setBoolForKey(true, key: IS_FROM_TODAY_WIDGET)
            let userDefaults : NSUserDefaults = NSUserDefaults(suiteName: APP_GROUP_TODAY_WIDGET)!
            let linkID : String = userDefaults.stringForKey("id")!
            Utilities.sharedInstance.setStringForKey(linkID, key: LINK_ID)
            print(linkID)
            self.loadFeedVC()
        }
        else if url.scheme == "informerly" {
            if (url.lastPathComponent != nil) {
                print(url.lastPathComponent!)
                Utilities.sharedInstance.setStringForKey(url.lastPathComponent!, key: LINK_ID)
                Utilities.sharedInstance.setBoolForKey(true, key: IS_FROM_CUSTOM_URL)
                self.loadFeedVC()
            }
        }
        return true
    }
    
    
    /* Method to check if the internet is connected or not.
        marks read locally saved feeds on server.
        bookmark locally saved feeds on server.
    */
    
    func checkForReachability(notification:NSNotification)
    {
        let networkReachability = notification.object as! Reachability;
        let remoteHostStatus = networkReachability.currentReachabilityStatus()
        
        if (remoteHostStatus.rawValue == NotReachable.rawValue)
        {
            print("Not Reachable")
        }
        else
        {
            print("Reachable")
            
            if Utilities.sharedInstance.getBoolForKey(IS_USER_LOGGED_IN) {
                
                if (NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) != nil) {
                    self.readArticles = NSUserDefaults.standardUserDefaults().objectForKey(READ_ARTICLES) as! Array
                    
                    if (readArticles != nil) && (readArticles?.isEmpty == false) {
                        self.markUnreadArticles(readArticles!)
                    }
                }
                
                let unbookmarkedFeeds:[BookmarkFeed] = CoreDataManager.getBookmarkFeeds()
                
                for feed in unbookmarkedFeeds {
                    if feed.isSynced == false {
                        self.markBookmarked(feed.id!)
                    }
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName("GetMenuItemsNotification", object: nil)
            }
        }
    }
    
    
    func markUnreadArticles(articlesList : [Int]){
        
        for articleID in articlesList {
            self.markRead(articleID)
        }
    }
    
    // Method to mark read articles on server.
    func markRead(articleID:Int) {
        let path : String = "links/\(articleID)/read"
        let parameters : [String:AnyObject] = [AUTH_TOKEN:Utilities.sharedInstance.getAuthToken(AUTH_TOKEN),
            "client_id":"",
            "link_id": articleID]
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(path,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                print("Successfully marked as read.")
                
                self.readArticles.removeAtIndex(self.readArticles.indexOf(articleID)!)
                NSUserDefaults.standardUserDefaults().setObject(self.readArticles, forKey: READ_ARTICLES)
                NSUserDefaults.standardUserDefaults().synchronize()
                
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                print("Failure marking article as read")
        }
    }
    
    // method to bookmark locally saved feeds.
    func markBookmarked(feedID:Int){
        let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
        
        let parameters : [String:AnyObject] = ["auth_token":auth_token,
            "client_id":"dev-ios-informer",
            "link_id":feedID]
        
        NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
            parameter: parameters,
            success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                
                if requestStatus == 200 {
                    var bookmarkDictionary : [String:AnyObject] = processedData.objectForKey("bookmark") as! Dictionary
                    let linkID = bookmarkDictionary["link_id"] as! Int
                    CoreDataManager.updateSyncStatusForFeedID(linkID, syncStatus: true)
                    print("Marked ...")
                }
            }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                print("Failed to bookmark ...")
        }
    }
    
    
    // Method load suitable controller
    func loadFeedVC(){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        if Utilities.sharedInstance.getStringForKey(LINK_ID) != "-1" {
            let root = self.window?.rootViewController as! MMDrawerController
            let nav = root.centerViewController as? UINavigationController
            
            if (nav != nil) {
                if nav!.topViewController?.isKindOfClass(ArticleViewController) == true {
                    nav!.popViewControllerAnimated(true)
                }
            }
        }
        
        let leftSideMenuViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("LeftMenuViewController")
        
        let rootVC = storyboard.instantiateViewControllerWithIdentifier("FeedVC") as! FeedViewController
        let navigationVC: UINavigationController = UINavigationController(rootViewController: rootVC)
        
        let container = MMDrawerController(centerViewController: navigationVC, leftDrawerViewController: leftSideMenuViewController)
        container.restorationIdentifier = "MMDrawer"
        container.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        container.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningDrawerView
        container.showsStatusBarBackgroundView = true
        container.statusBarViewBackgroundColor = UIColor.whiteColor()
        container.maximumLeftDrawerWidth = 220
        self.window?.rootViewController = container
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mycompany.test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
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
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
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
        } catch {
            fatalError()
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
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
    // Configures push notification for the user.
    func configurePushNotification() {
        
        let openAction = UIMutableUserNotificationAction()
        openAction.title = NSLocalizedString("Open", comment: "")
        openAction.identifier = "open"
        openAction.activationMode = UIUserNotificationActivationMode.Foreground
        openAction.authenticationRequired = false
        openAction.destructive = false
        
        let saveAction = UIMutableUserNotificationAction()
        saveAction.title = NSLocalizedString("Save", comment: "")
        saveAction.identifier = "save"
        saveAction.activationMode = UIUserNotificationActivationMode.Background
        saveAction.authenticationRequired = false
        saveAction.destructive = false
        
        
        let notificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.setActions([openAction, saveAction],
            forContext: UIUserNotificationActionContext.Default)
        notificationCategory.identifier = "notification"
        
        
        let categories = Set<UIUserNotificationCategory>(arrayLiteral: notificationCategory)
        
        // Configure other actions and categories and add them to the set...
        
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: categories)
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications();
    }

    // Method to handle notification actions.
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        if identifier == "open" {
            
            //Mixpanel track
            Mixpanel.sharedInstance().track("Notification - Open")
            
            let link_id = userInfo["link_id"] as! Int
            Utilities.sharedInstance.setStringForKey("\(link_id)", key: LINK_ID)
            Utilities.sharedInstance.setBoolForKey(true, key: IS_FROM_PUSH)
            completionHandler()
        } else if identifier == "save" {
            
            //Mixpanel track
            Mixpanel.sharedInstance().track("Notification - Save")
            
            let token : String! = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            
            if token != nil && token != "" {
                let parameters : [String:AnyObject] = ["auth_token":token,
                    "client_id":"dev-ios-informer",
                    "link_id":userInfo["link_id"] as! Int]
                
                if Utilities.sharedInstance.isConnectedToNetwork() == true {
                    NetworkManager.sharedNetworkClient().processPostRequestWithPath(BOOKMARK_URL,
                        parameter: parameters,
                        success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                            if requestStatus == 200 {
                                var bookmarkDictionary : [String:AnyObject] = processedData.objectForKey("bookmark") as! Dictionary
                                let linkID = bookmarkDictionary["link_id"] as! Int
                                self.downloadArticleData("\(linkID)",completionHandler: completionHandler)
                            }
                        }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                            
                            if extraInfo != nil {
                                
                            }
                            completionHandler()
                    }
                }
            }
        }
    }
    
    // Method to fetch article data.
    func downloadArticleData(articleID : String,completionHandler: () -> Void) {
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let parameters = ["auth_token":auth_token,
                "client_id":"dev-ios-informer",
                "content":"true"]
            
            NetworkManager.sharedNetworkClient().processGetRequestWithPath("links/\(articleID)",
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    var data : [String:AnyObject] = processedData.objectForKey("link") as! Dictionary
                    
                    let feed : BookmarkFeed = BookmarkFeed()
                    feed.id = data["id"] as? Int
                    feed.title = data["title"] as? String
                    feed.feedDescription = data["description"] as? String
                    feed.content = data["content"] as? String
                    feed.readingTime = data["reading_time"] as? Int
//                    feed.source = data["source"] as? String
                    feed.sourceColor = data["source_color"] as? String
                    feed.url = data["url"] as? String
                    feed.read = data["read"] as? Bool
                    feed.bookmarked = true
                    feed.publishedAt = data["published_at"] as? String
                    feed.originalDate = data["original_date"] as? String
                    feed.shortLink = data["shortLink"] as? String
                    feed.slug = data["slug"] as? String
                    
                    CoreDataManager.addBookmarkFeed(feed, isSynced: true)
                    completionHandler()
                    
                }, failure: { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    completionHandler()
            })
            
        }
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let webpageURL = userActivity.webpageURL! // Always exists
            if !handleUniversalLink(URL: webpageURL) {
                UIApplication.sharedApplication().openURL(webpageURL)
            }
        }
        return true
    }
    
    private func handleUniversalLink(URL url: NSURL) -> Bool {
        
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true), let host = components.host {
            switch host {
            case "informerly.com":
                
                if (Utilities.sharedInstance.getBoolForKey(IS_USER_LOGGED_IN) == true) {
                    if let lastComponent = Int(url.lastPathComponent!) {
                        Utilities.sharedInstance.setStringForKey(String(lastComponent), key: LINK_ID)
                    } else {
                        Utilities.sharedInstance.setStringForKey("-2", key: LINK_ID)
                        Utilities.sharedInstance.setStringForKey(url.lastPathComponent!, key: SLUG)
                    }
                    self.loadFeedVC()
                }
                
                return true
                
            default:
                return false
            }
            
        }
        return false
    }
    
}