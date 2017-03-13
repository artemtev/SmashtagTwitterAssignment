//
//  Mension+CoreDataProperties.swift
//  Smashtag
//
//  Created by Admin on 13.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import CoreData


extension Mension {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mension> {
        return NSFetchRequest<Mension>(entityName: "Mension");
    }

    @NSManaged public var count: Int32
    @NSManaged public var type: String?
    @NSManaged public var keyword: String?
    @NSManaged public var term: SearchTerm?

}
