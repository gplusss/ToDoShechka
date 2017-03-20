//
//  Task.swift
//  ToDoShechka
//
//  Created by Vladimir Saprykin on 19.03.17.
//  Copyright © 2017 Vladimir Saprykin. All rights reserved.
//

import Foundation
import Firebase

struct Task {
    let title: String
    let userId: String
    let ref: FIRDatabaseReference?
    var completed: Bool = false
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    init(snapShort: FIRDataSnapshot) {
        let snapshotValue = snapShort.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapShort.ref
    }
    
    func convertToDictionary() -> Any {
        return ["title": title, "userId": userId, "completed": completed]
    }
}
