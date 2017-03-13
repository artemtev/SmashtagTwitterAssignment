//
//  TweetCD+CoreDataProperties.swift
//  Smashtag
//
//  Created by Admin on 13.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import CoreData


extension TweetCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TweetCD> {
        return NSFetchRequest<TweetCD>(entityName: "TweetCD");
    }

    @NSManaged public var posted: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var unique: String
    @NSManaged public var terms: Set<SearchTerm>

}


