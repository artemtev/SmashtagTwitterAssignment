//
//  TweetMentionsTableViewController.swift
//  Smashtag
//
//  Created by Admin on 12.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter

class TweetMentionsTableViewController: UITableViewController {

    var tweet: Twitter.Tweet? {
        
        didSet {
            title = tweet?.user.screenName
            if let media = tweet?.media  , media.count > 0 {
                mentionSections.append(MentionSection(type: "Images",
                                                      mentions: media.map { MentionItem.image($0.url, $0.aspectRatio) }))
            }
            if let urls = tweet?.urls  , urls.count > 0 {
                mentionSections.append(MentionSection(type: "URLs",
                                                      mentions: urls.map { MentionItem.keyword($0.keyword) }))
            }
            if let hashtags = tweet?.hashtags , hashtags.count > 0 {
                mentionSections.append(MentionSection(type: "Hashtags",
                                                      mentions: hashtags.map { MentionItem.keyword($0.keyword) }))
            }
            if let users = tweet?.userMentions {
                var userItems = [MentionItem]()
                if let screenName = tweet?.user.screenName {
                    userItems += [MentionItem.keyword("@" + screenName)]
                }
                if users.count > 0 {
                    userItems += users.map { MentionItem.keyword($0.keyword) }
                }
                if userItems.count > 0 {
                    mentionSections.append(MentionSection(type: "Users", mentions: userItems))
                }
            }
        }
    }
    
    
    var mentionSections = [MentionSection]()
    
    
    enum MentionItem: CustomStringConvertible
    {
        case keyword(String)
        case image(URL, Double)
        
        var description: String {
            switch self {
            case .keyword(let keyword): return keyword
            case .image(let url, _): return url.path
            }
        }
    }
    
    
    struct MentionSection: CustomStringConvertible
    {
        var type: String
        var mentions: [MentionItem]
        var description: String { return "\(type): \(mentions)" }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentionSections.count
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return mentionSections[section].mentions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        
        let mention = mentionSections[indexPath.section].mentions[indexPath.row]
        
        switch mention {
        case .keyword(let keyword):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.KeywordCellIdentifier,
                                                     for: indexPath)
            cell.textLabel?.text = keyword
            cell.textLabel?.textColor = TweetTableViewCell.Colors.hashtag
            return cell
            
        case .image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.ImageCellIdentifier,
                                                     for: indexPath)
            if let imageCell = cell as? MentionImageTableViewCell {
                imageCell.imageUrl = url
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let mention = mentionSections[indexPath.section].mentions[indexPath.row]
        switch mention {
        case .image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return mentionSections[section].type
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Identifiers.KeywordSegueIdentifier:
                if let ttvc = segue.destination as? TweetsTableViewController, let cell = sender as? UITableViewCell, var text = cell.textLabel?.text {
                    if text.hasPrefix("@") {
                        text += " or from:" + text
                    }
                    ttvc.searchText = text
                }
            case Identifiers.ImageSegueIdentifier:
                if let mivc = segue.destination as? MentionImageViewController, let cell = sender as? MentionImageTableViewCell {
                    mivc.imageURL = cell.imageUrl
                    mivc.title = title
                }
            case Identifiers.WebSegueIdentifier:
                if let uvc = segue.destination as? URLViewController {
                    if let cell = sender as? UITableViewCell {
                        if let url = cell.textLabel?.text {
                            uvc.url = URL(string: url)
                        }
                    }
                }
            default: break
                
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?,
                                     sender: Any?) -> Bool {
        if identifier == Identifiers.KeywordSegueIdentifier {
            if let cell = sender as? UITableViewCell,
                let indexPath =  tableView.indexPath(for: cell)
                , mentionSections[indexPath.section].type == "URLs" {
                performSegue(withIdentifier: Identifiers.WebSegueIdentifier, sender: sender)
                return false
            }
        }
        return true
    }

}
