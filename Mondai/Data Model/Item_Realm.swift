//
//  Item_Realm.swift
//  Mondai
//
//  Created by Christian Stevanus on 27/01/19.
//  Copyright © 2019 Christian Stevanus. All rights reserved.
//

import Foundation
import RealmSwift

class Item_Realm: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category_Realm.self, property: "items")
}
