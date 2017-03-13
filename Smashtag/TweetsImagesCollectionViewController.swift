//
//  TweetsImagesCollectionViewController.swift
//  Smashtag
//
//  Created by Admin on 12.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Twitter


class TweetsImagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var tweets: [[Twitter.Tweet]] = [] {
        didSet {
            images = tweets.flatMap({$0}).map( { tweet in
                tweet.media.map {
                    Media(tweet: tweet, media: $0)
                }} ).flatMap({$0})
        }
    }

    var images = [Media]()
    var cache = NSCache<AnyObject, AnyObject>()
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width/3 - 0.667, height: width/3 - 0.667)
        
    }
    
    func setupLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.minimumInteritemSpacing = 1.0
        collectionView?.collectionViewLayout = flowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.ImageCollectionViewCellIdentifier, for: indexPath) as? TweetImageCollectionViewCell
        
    
        cell?.cache = cache
        cell?.media = images[indexPath.row]
    
        return cell ?? UICollectionViewCell()
    }


}
