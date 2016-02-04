//
//  SecondInterfaceController.swift
//  Informerly
//
//  Created by Apple on 16/09/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import WatchKit
import Foundation

class SecondInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var sourceLabel: WKInterfaceLabel!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if (context != nil) {
            loadData(context!)
        }
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    func loadData(data:AnyObject){
        var feed : [String:AnyObject] = data as! [String : AnyObject]
        self.sourceLabel.setText(feed["source"] as? String)
        self.sourceLabel.setTextColor(UIColor(rgba: feed["source_color"] as! String))
        self.titleLabel.setText(feed["title"] as? String)
        self.descriptionLabel.setText(feed["description"] as? String)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
