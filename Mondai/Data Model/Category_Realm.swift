//
//  Category_Realm.swift
//  Mondai
//
//  Created by Christian Stevanus on 27/01/19.
//  Copyright © 2019 Christian Stevanus. All rights reserved.
//

import Foundation
import RealmSwift

class Category_Realm: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item_Realm>()
    let array = Array<Int>()
}
