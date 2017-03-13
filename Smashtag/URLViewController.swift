//
//  URLViewController.swift
//  Smashtag
//
//  Created by Admin on 12.03.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class URLViewController: UIViewController, UIWebViewDelegate {
    
    var url: URL?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    @IBOutlet weak var URLWebView: UIWebView! {
        didSet {
            if url != nil {
                URLWebView.delegate = self
                self.title = url!.host
                URLWebView.scalesPageToFit = true
                URLWebView.loadRequest(NSURLRequest(url: url!) as URLRequest)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.stopAnimating()
        print("ERROR: Can't load the page")
    }
    

}
