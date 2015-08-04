//
//  User.swift
//  Informerly
//
//  Created by Apple on 02/02/2015.
//  Copyright (c) 2015 Informerly. All rights reserved.
//

import Foundation

class User {

    var auth_token: String!
    var id: Int!
    var user_name: String!
    var full_name : String!
    
    class var sharedInstance :User {
        struct Singleton {
            static let instance = User()
        }
        
        return Singleton.instance
    }
    
    func populateUser(data:Dictionary<String,AnyObject>){
        
        var user : [String:AnyObject] = data["user"] as! Dictionary
        self.auth_token = data["auth_token"] as! String
        self.id = user["id"] as! Int
        self.user_name = user["username"] as! String
        self.full_name = user["full_name"] as! String
    }
    
    func getUser()->User {
        return self;
    }
}