//
//  SearchTerm+CoreDataClass.swift
//  Smashtag
//
//  Created by Admin on 13.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import CoreData


public class SearchTerm: NSManagedObject {

    class func termWith(term: String,
                        inContext context: NSManagedObjectContext) -> SearchTerm?
    {
        let request: NSFetchRequest<SearchTerm> = SearchTerm.fetchRequest()
        request.predicate = NSPredicate(format: "term = %@", term)
        if let searchTerm = (try? context.fetch(request))?.first {
            return searchTerm
        } else {
            let searchTerm = SearchTerm(context: context)
            searchTerm.term = term
            return  searchTerm
        }
    }
    
    override public func prepareForDeletion() {
        if  mensions.count > 0 {
            for mension in mensions {
                managedObjectContext?.delete(mension)
            }
        }
        if  tweets.count > 0 {
            for tweet in tweets {
                if    tweet.terms.filter ({ !($0 as AnyObject).isDeleted }).isEmpty {
                    managedObjectContext?.delete(tweet)
                }
            }
        }
    }
    
}
