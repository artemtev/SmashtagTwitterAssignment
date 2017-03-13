//
//  MentionImageViewController.swift
//  Smashtag
//
//  Created by Admin on 12.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class MentionImageViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    @IBOutlet weak var imageScrollView: UIScrollView! {
        didSet {
            imageScrollView.contentSize = imageView.frame.size
            imageScrollView.delegate = self
            imageScrollView.maximumZoomScale = 2.0
            imageScrollView.minimumZoomScale = 0.3
        }
    }
    
    
    private var autoZoomed = true
    
    private func zoomScaleToFit() {
        if !autoZoomed {
            return
        }
        if let sv = imageScrollView, image != nil && (imageView.bounds.size.width > 0) && (imageScrollView.bounds.size.width > 0) {
            let widthRatio = imageScrollView.bounds.size.width/imageView.bounds.size.width
            let heightRatio = imageScrollView.bounds.size.height/imageView.bounds.size.height
            sv.zoomScale = (widthRatio > heightRatio) ? widthRatio : heightRatio
            sv.contentOffset = CGPoint(x: (imageView.frame.size.width - sv.frame.size.width) / 2, y: (imageView.frame.size.height - sv.frame.size.height) / 2)
        }
    }

    var imageURL: URL? {
        didSet {
            image = nil
            fetchImage()
        }
    }
    
    var imageView = UIImageView()
    
    var image: UIImage? {
        get {
            return imageView.image
        } set {
            imageView.image = newValue
            imageView.sizeToFit()
            imageScrollView?.contentSize = imageView.frame.size
            autoZoomed = true
            zoomScaleToFit()
        }
    }
    
    func fetchImage() {
        spinner?.startAnimating()
        if let url = imageURL {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: imageData)
                    }
                    self.spinner?.stopAnimating()
                }
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        autoZoomed = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.addSubview(imageView)
        zoomScaleToFit()
    }

}
