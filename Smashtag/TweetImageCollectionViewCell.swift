//
//  TweetImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Admin on 12.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter

class TweetImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tweetImageView: UIImageView!
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var cache: NSCache<AnyObject, AnyObject>?
    
    var media: Media? {
        didSet {
            imageURL = media?.media.url
            fetchImage()
        }
    }
    
    var imageURL: URL? {
        didSet {
            fetchImage()
        }
    }
    
    var image: UIImage? {
        get {
            return tweetImageView.image
        } set {
            tweetImageView.image = newValue
            spinner?.stopAnimating()
        }
    }
    
    
    func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()
            let imageData = cache?.object(forKey: url as AnyObject) as? Data
            guard imageData == nil else {
                image = UIImage(data: imageData!)
                return
            }
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                            self.cache?.setObject(imageData as AnyObject, forKey: url as AnyObject, cost: imageData.count/1024)
                        }
                    }
                }
            }
        }
    }
    
    
}

struct Media {
    var tweet: Twitter.Tweet
    var media: MediaItem
    
    public var description: String {
        return "\(tweet) : \(media)"
    }
}
