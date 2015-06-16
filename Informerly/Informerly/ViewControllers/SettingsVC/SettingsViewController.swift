//
//  SettingsViewController.swift
//  Informerly
//
//  Created by Apple on 10/06/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation
class SettingsViewController : UIViewController {
    
    @IBOutlet weak var articleViewSwitch: UISwitch!
    @IBOutlet weak var defaultListSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up Nav bar
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Settings"
        
        // Create bar buttons
        self.createNavButtons()
        
        if Utilities.sharedInstance.getStringForKey(DEFAULT_ARTICLE_VIEW) == "zen" {
            articleViewSwitch.setOn(true, animated: true)
        }
        
        if Utilities.sharedInstance.getStringForKey(DEFAULT_LIST) == "unread" {
            defaultListSwitch.setOn(true, animated: true)
        }
    }
    
    func createNavButtons() {
        var doneBtn : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("onDonePress:"))
        
        self.navigationItem.rightBarButtonItem = doneBtn
        
    }
    
    func onDonePress(sender:AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onDefaultZenViewSwtichValueChanged(sender: UISwitch) {
        var mode = ""
        if sender.on == true {
            mode = "zen"
        } else {
            mode = "web"
        }
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            var parameters : [String:AnyObject] = ["auth_token":auth_token,
                "preferences":["default_article_view":mode]]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(UPDATE_USER_PREFERENCES_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        Utilities.sharedInstance.setStringForKey(mode, key: DEFAULT_ARTICLE_VIEW)
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    println("Error")
            }
            
        }
    }
    
    @IBAction func onDefaultListSwitchValueChanged(sender: UISwitch) {
        var mode = ""
        if sender.on == true {
            mode = "unread"
        } else {
            mode = "all"
        }
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            var auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            var parameters : [String:AnyObject] = ["auth_token":auth_token,
                "preferences":["default_list":mode]]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(UPDATE_USER_PREFERENCES_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        Utilities.sharedInstance.setStringForKey(mode, key: DEFAULT_LIST)
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    println("Error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}