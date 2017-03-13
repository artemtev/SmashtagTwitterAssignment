//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Admin on 11.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    struct Colors {
        static let hashtag = UIColor(red: 76.0/255.0, green: 179.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        static let url = UIColor(red: 76.0/255.0, green: 179.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    }
    
    private func setTextLabel(tweet: Tweet) -> NSMutableAttributedString {
        var tweetText: String = tweet.text
        for _ in tweet.media {
            tweetText += " 📷"
        }
        
        let attribText = NSMutableAttributedString(string: tweetText)
        
        attribText.setMensionsColor(mensions: tweet.urls, color: Colors.url)
        attribText.setMensionsColor(mensions: tweet.hashtags, color: Colors.hashtag)
        attribText.setMensionsColor(mensions: tweet.userMentions, color: UIColor.black)
        
        return attribText
        
    }
    
    private func updateUI() {
        userName?.text = nil
        createdDate?.text = nil
        tweetText?.attributedText = nil
        userImage?.image = nil
        
        if let tweet = self.tweet {
            tweetText?.text = tweet.text
            if tweetText?.text != nil {
                tweetText?.attributedText = setTextLabel(tweet: tweet)
                for tweetParts in (tweetText?.text?.components(separatedBy: " "))! {
                    if tweetParts.hasPrefix("http") || tweetParts.hasPrefix("@") {
                        (tweetText?.attributedText as? NSMutableAttributedString)?.addAttribute(NSForegroundColorAttributeName, value: Colors.url, range: (tweetText!.text! as NSString).range(of: tweetParts))
                    }
                }
                
            }
            
            userName?.text = "\(tweet.user)"
            
            for nameParts in (userName?.text?.components(separatedBy: " "))! {
                if nameParts.hasPrefix("\n@") {
                    (userName?.attributedText as? NSMutableAttributedString)?.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range: (userName!.text! as NSString).range(of: nameParts))
                }
            }
            
            if let profileImageURL = tweet.user.profileImageURL {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    if let data = try? Data(contentsOf: profileImageURL) {
                        DispatchQueue.main.async {
                            self.userImage?.image = UIImage(data: data)
                            self.userImage?.layer.cornerRadius = 8.0
                            self.userImage?.clipsToBounds = true
                        }
                    }
                }
            }
            
            let formatter = DateFormatter()
            if  Date().timeIntervalSince(tweet.created) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            createdDate?.text = "• " + formatter.string(from: tweet.created)
            createdDate?.textColor = UIColor.gray
            
        }
        tweetText.sizeToFit()
    }
    
    
}

extension NSMutableAttributedString {
    func setMensionsColor(mensions: [Mention], color: UIColor) {
        for mension in mensions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mension.nsrange)
        }
    }
}
