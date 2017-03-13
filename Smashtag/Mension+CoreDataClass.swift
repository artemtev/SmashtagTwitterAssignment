//
//  Mension+CoreDataClass.swift
//  Smashtag
//
//  Created by Admin on 13.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import CoreData
import Twitter


public class Mension: NSManagedObject {
    
    class func addMension(keyword: String,
                          andType type: String,
                          andTerm term: SearchTerm,
                          inContext context: NSManagedObjectContext) -> Mension?
    {
        let request: NSFetchRequest<Mension> = Mension.fetchRequest()
        request.predicate = NSPredicate(format: "keyword LIKE[cd] %@ AND term.term = %@",
                                        keyword, term.term)
        
        if let mentionM = (try? context.fetch(request))?.first  {
            mentionM.count = Int32(NSNumber( value: Int(mentionM.count) + 1))
            return mentionM
        } else {
            let mentionM = Mension(context: context)
            mentionM.keyword = keyword
            mentionM.type = type
            mentionM.term = term
            mentionM.count = 1
            return mentionM
        }
    }
    
    class func mensionsWith(twitterInfo: Twitter.Tweet,
                            andSearchTerm term: SearchTerm,
                            inContext context: NSManagedObjectContext)
    {
        let hashtags = twitterInfo.hashtags
        for hashtag in hashtags{
            _ =   Mension.addMension(keyword: hashtag.keyword,
                                     andType: "Hashtags", andTerm: term,
                                     inContext: context)
        }
        let users = twitterInfo.userMentions
        for user in users {
            _ =  Mension.addMension(keyword: user.keyword, andType: "Users", andTerm: term,
                                    inContext: context)
        }
        let userScreenName = "@" + twitterInfo.user.screenName
        _ = Mension.addMension(keyword: userScreenName, andType: "Users", andTerm: term,
                               inContext: context)
        
    }

}
