//
//  ActionViewController.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/9/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import UIKit
import WebKit

class ActionViewController: UIViewController, WKNavigationDelegate
{   @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var labelStatus: UILabel!
    private var action: PersonyzeAction? = nil

    override func viewDidLoad()
    {   super.viewDidLoad()
		webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        load()
    }

    func setAction(action: PersonyzeAction)
    {   self.action = action
        if webView != nil
        {   load()
        }
    }
    
    private func load()
    {   if let action = action
        {   // Save html to file to find it in debugger
            let f = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("content.html").path
            print("HTML saved to \(f) - so you can find it in debugger")
            try? action.contentHtmlDoc?.write(toFile: f, atomically: false, encoding: .utf8)
            // Load
            labelStatus.text = " "
            loading.startAnimating()
            if action.contentType == "text/html"
            {   action.renderOnWebkitView(webView)
                {   clicked in
					// Got event. This means that you clicked some sensitive region
					// I report this event to Personyze. So there will be CTR and close-rate statistics, and widget contribution rate (products bought from this action)
                    PersonyzeTracker.inst.reportActionClicked(clicked: clicked)
					// Also i show the event on screen
                    self.labelStatus.text = "clicked=\(clicked.status); arg=\(clicked.arg); href=\(clicked.href)"
                }
            }
            else
            {   let html =
                """
                <html>
                <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                </head>
                <body>
                <plaintext>\(action.content)
                """
                webView?.loadHTMLString(html, baseURL: nil)
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{	if keyPath == "estimatedProgress"
		{	if Float(webView.estimatedProgress) >= 1
            {   loading.stopAnimating()
            }
		}
	}
}
