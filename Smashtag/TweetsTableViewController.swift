//
//  TweetsTableViewController.swift
//  Smashtag
//
//  Created by Admin on 11.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetsTableViewController: UITableViewController, UISearchBarDelegate {

    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    
    @IBOutlet weak var searchField: UISearchBar! {
        didSet {
            searchField.delegate = self
            searchField.text = searchText
        }
    }
    
    var tweets = [[Tweet]]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    var searchText: String? {
        didSet {
            lastRequest = nil
            tweets.removeAll()
            title = searchText
            searchTweets()
            searchField.text = searchText
            HistoryDefaults.add(searchText!)
        }
    }
    
    var request: Twitter.Request? {
        
        if lastRequest == nil {
            if let query = searchText, !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 100)
            }
        }
        
        return lastRequest?.requestForNewer
    }
    
    var lastRequest: Twitter.Request?
    
    func searchTweets() {
        refreshControl?.beginRefreshing()
        search(refreshControl)
    }
    
    
    @IBAction func search(_ sender: UIRefreshControl?) {
        if let request1 = request {
            lastRequest = request1
            request1.fetchTweets { [weak weakSelf = self] newTweets in
                DispatchQueue.main.async {
                    if request1 == weakSelf?.lastRequest {
                        
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, at: 0)
                            weakSelf?.tableView.reloadData()
                            sender?.endRefreshing()
                            
                           weakSelf?.updateDatabase(newTweets: newTweets,searchTerm:(weakSelf?.searchText)!)
                            
                        }
                    }
                    sender?.endRefreshing()
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    func updateDatabase(newTweets: [Tweet], searchTerm: String) {
        
        container?.performBackgroundTask { context in
            TweetCD.newTweetsWith(twitterInfo: newTweets,andSearchTerm: searchTerm,
                                 inContext: context)
            context.saveThrows()
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweets[section].count
    }
    
    
    func showImages(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Identifiers.ImagesSegueIdentifier, sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let imageButton = UIBarButtonItem(barButtonSystemItem: .camera,
                                          target: self,
                                          action: #selector(TweetsTableViewController.showImages(_:)))
        navigationItem.rightBarButtonItems = [imageButton]
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TweetCellIdentifier, for: indexPath) as? TweetTableViewCell
        
        let tweet = tweets[indexPath.section][indexPath.row]
        

        cell?.tweet = tweet

        return cell ?? UITableViewCell()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Identifiers.MentionsSegueIdentifier, let tmtvc = segue.destination as? TweetMentionsTableViewController, let tweetCell = sender as? TweetTableViewCell {
                tmtvc.tweet = tweetCell.tweet
                
            } else if identifier == Identifiers.ImagesSegueIdentifier {
                if let ticvc = segue.destination as? TweetsImagesCollectionViewController {
                    ticvc.tweets = tweets
                    ticvc.title = "Images for: \(searchText!)"
                }
            }
        }
    }
}

extension NSManagedObjectContext
{
    public func saveThrows () {
        if self.hasChanges {
            do {
                try save()
            } catch let error  {
                let nserror = error as NSError
                print("Core Data Error:  \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
