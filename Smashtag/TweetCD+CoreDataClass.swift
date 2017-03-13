//
//  TweetCD+CoreDataClass.swift
//  Smashtag
//
//  Created by Admin on 13.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import CoreData
import Twitter


public class TweetCD: NSManagedObject {
    
    class func tweetWith (twitterInfo: Twitter.Tweet,
                          inContext context: NSManagedObjectContext) -> TweetCD?
    {
        let request: NSFetchRequest<TweetCD> = TweetCD.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweetCD = (try? context.fetch(request))?.first {
            return tweetCD
        } else {
            let tweetCD = TweetCD(context: context)
            tweetCD.unique = twitterInfo.id
            tweetCD.text = twitterInfo.text
            tweetCD.posted = twitterInfo.created as NSDate?
            return tweetCD
        }
    }
    
    class func newTweetsWith(twitterInfo: [Twitter.Tweet],
                             andSearchTerm term: String,
                             inContext context: NSManagedObjectContext)
    {
        guard let currentTerm = SearchTerm.termWith(term: term, inContext: context)
            else {return}
        let newTweetsId = twitterInfo.map {$0.id}
        var newsSet = Set (newTweetsId)
        
        let request: NSFetchRequest<TweetCD> = TweetCD.fetchRequest()
        request.predicate = NSPredicate(
            format: "any terms.term contains[c] %@ and unique IN %@", term, newsSet)
        
        let results = try? context.fetch(request)
        if let tweets =  results  {
            let oldTweetsId  = tweets.flatMap({ $0.unique})
            let oldsSet = Set (oldTweetsId)
            
            newsSet.subtract(oldsSet)
            print ("-----------кол-во новых элементов \(newsSet.count)-----")
            
            for unique in newsSet {
                if let index = twitterInfo.index(where: {$0.id == unique}){
                    if let tweetCD = TweetCD.tweetWith (twitterInfo: twitterInfo[index],
                                                      inContext: context){
                        tweetCD.terms.insert(currentTerm)
                        Mension.mensionsWith(twitterInfo: twitterInfo[index],
                                             andSearchTerm: currentTerm,
                                             inContext: context)
                    }
                }
            }
        }
    }

}
