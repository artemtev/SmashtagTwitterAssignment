//
//  SearchTerm+CoreDataProperties.swift
//  Smashtag
//
//  Created by Admin on 13.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import CoreData


extension SearchTerm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchTerm> {
        return NSFetchRequest<SearchTerm>(entityName: "SearchTerm");
    }

    @NSManaged public var term: String
    @NSManaged public var mensions: Set<Mension>
    @NSManaged public var tweets: Set<TweetCD>

}

