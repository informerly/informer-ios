//
//  ArticleInterfaceController.swift
//  Informerly
//
//  Created by Apple on 12/08/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import WatchKit
import Foundation

class ArticleInterfaceController: WKInterfaceController {
    @IBOutlet weak var articleDescriptionLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if context != nil {
            let description = context as! String
            articleDescriptionLabel.setText(description)
        } else {
            articleDescriptionLabel.setText("no description found")
        }
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
