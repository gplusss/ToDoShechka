//
//  User.swift
//  ToDoShechka
//
//  Created by Vladimir Saprykin on 19.03.17.
//  Copyright © 2017 Vladimir Saprykin. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    
    init(user: FIRUser) {
        self.uid = user.uid
        self.email = user.email!
    }
}
