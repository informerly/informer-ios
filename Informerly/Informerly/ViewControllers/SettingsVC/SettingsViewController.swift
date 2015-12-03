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
    
    var email:String!
    var userID:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up Nav bar
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.hidesBackButton = true
        
        email = Utilities.sharedInstance.getStringForKey(EMAIL)!
        userID = Utilities.sharedInstance.getStringForKey(USER_ID)!
        
        let title : UILabel = UILabel(frame: CGRectMake(0, 0, 70, 30))
        title.textAlignment = NSTextAlignment.Center
        title.text = "Settings"
        title.font = UIFont(name: "OpenSans", size: 16.0)
        title.textColor = UIColor(rgba: "#4A4A4A")
        self.navigationItem.titleView = title
        
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
        let doneBtn : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onDonePress:"))
        
        doneBtn.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "OpenSans", size: 16.0)!], forState: UIControlState.Normal)
        
        self.navigationItem.rightBarButtonItem = doneBtn
        
    }
    
    func onDonePress(sender:AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onDefaultZenViewSwtichValueChanged(sender: UISwitch) {
        
        //Mixpanel track
        let properties : [String:String] = ["UserID":self.userID,"Email":self.email]
        Mixpanel.sharedInstance().track("Change Zen Setting",properties: properties)
        
        var mode = ""
        if sender.on == true {
            mode = "zen"
        } else {
            mode = "web"
        }
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let parameters : [String:AnyObject] = ["auth_token":auth_token,
                "preferences":["default_article_view":mode]]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(UPDATE_USER_PREFERENCES_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        Utilities.sharedInstance.setStringForKey(mode, key: DEFAULT_ARTICLE_VIEW)
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    print("Error")
            }
            
        }
    }
    
    @IBAction func onDefaultListSwitchValueChanged(sender: UISwitch) {
        
        //Mixpanel track
        let properties : [String:String] = ["UserID":self.userID,"Email":self.email]
        Mixpanel.sharedInstance().track("Change Unread Setting",properties: properties)
        
        var mode = ""
        if sender.on == true {
            mode = "unread"
        } else {
            mode = "all"
        }
        
        if Utilities.sharedInstance.isConnectedToNetwork() == true {
            let auth_token = Utilities.sharedInstance.getAuthToken(AUTH_TOKEN)
            let parameters : [String:AnyObject] = ["auth_token":auth_token,
                "preferences":["default_list":mode]]
            
            NetworkManager.sharedNetworkClient().processPostRequestWithPath(UPDATE_USER_PREFERENCES_URL,
                parameter: parameters,
                success: { (requestStatus:Int32, processedData:AnyObject!, extraInfo:AnyObject!) -> Void in
                    if requestStatus == 200 {
                        Utilities.sharedInstance.setStringForKey(mode, key: DEFAULT_LIST)
                    }
                }) { (requestStatus:Int32, error:NSError!, extraInfo:AnyObject!) -> Void in
                    print("Error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}