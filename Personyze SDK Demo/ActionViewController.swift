//
//  ActionViewController.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/9/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import Personyze
import UIKit
import WebKit

/// The third screen: one action. An HTML action renders in the SDK's view, which reports it shown,
/// reports taps on it, opens its links and hides on close; other content types show as text.
class ActionViewController: UIViewController
{	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var loading: UIActivityIndicatorView!
	@IBOutlet weak var labelStatus: UILabel!

	private var action: PersonyzeAction?
	private var actionView: PersonyzeActionView?

	override func viewDidLoad()
	{	super.viewDidLoad()
		load()
	}

	func setAction(action: PersonyzeAction)
	{	self.action = action
		if isViewLoaded
		{	load()
		}
	}

	private func load()
	{	guard let action else
		{	return
		}
		labelStatus.text = " "
		if let html = action.contentHtmlDocument()
		{	// The page the SDK renders, saved to look at in the debugger.
			if let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
			{	let file = caches.appendingPathComponent("content.html")
				try? html.write(to: file, atomically: false, encoding: .utf8)
				print("HTML saved to \(file.path)")
			}
			loading.startAnimating()
			(actionView ?? makeActionView()).render(action)
		}
		else
		{	actionView?.isHidden = true
			webView.isHidden = false
			let text = action.content ?? "The template has not loaded yet"
			webView.loadHTMLString("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></head><body><plaintext>" + text, baseURL: nil)
		}
	}

	/// In the storyboard web view's place.
	private func makeActionView() -> PersonyzeActionView
	{	let view = PersonyzeActionView()
		// Fill the screen and scroll, as the web view here did. In a list or a stack, the default
		// (true) makes it as tall as its content.
		view.autoHeight = false
		view.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
		view.onHeightChange = { [weak self] _ in
			self?.loading.stopAnimating()
		}
		view.onClick = { [weak self] click in
			self?.labelStatus.text = "\(click.kind) \(click.arg) \(click.href)"
			// Not handled here: the SDK opens the link, or hides the action on close.
			return false
		}
		if let stack = webView.superview as? UIStackView, let i = stack.arrangedSubviews.firstIndex(of: webView)
		{	stack.insertArrangedSubview(view, at: i)
		}
		webView.isHidden = true
		actionView = view
		return view
	}
}
