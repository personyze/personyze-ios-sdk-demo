//
//  DemoViewController.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/8/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import Personyze
import UIKit

/// An event the demo collects before sending it.
private enum Event
{	case profile(field: String, value: String)
	case productViewed(String)
	case productAddedToCart(String)
	case productLiked(String)
	case productPurchased(String)
	case productUnliked(String)
	case productRemovedFromCart(String)
	case productsPurchased
	case productsUnliked
	case productsRemovedFromCart
	case articleViewed(String)
	case articleLiked(String)
	case articleCommented(String)
	case articleUnliked(String)
	case articleGoal(String)

	/// The SDK call for the event: on a navigation's events, attributed to the new screen, or
	/// straight on the client.
	func send(to events: DemoEvents)
	{	switch self
		{	case .profile(let field, let value):
				events.setProfile(field, value)
			case .productViewed(let id):
				events.productViewed(id, actionId: nil)
			case .productAddedToCart(let id):
				events.productAddedToCart(id, actionId: nil, quantity: nil)
			case .productLiked(let id):
				events.productLiked(id, actionId: nil)
			case .productPurchased(let id):
				events.productPurchased(id, actionId: nil, quantity: nil)
			case .productUnliked(let id):
				events.productUnliked(id, actionId: nil)
			case .productRemovedFromCart(let id):
				events.productRemovedFromCart(id, actionId: nil, quantity: nil)
			case .productsPurchased:
				events.productsPurchased()
			case .productsUnliked:
				events.productsUnliked()
			case .productsRemovedFromCart:
				events.productsRemovedFromCart()
			case .articleViewed(let id):
				events.articleViewed(id, actionId: nil)
			case .articleLiked(let id):
				events.articleLiked(id, actionId: nil)
			case .articleCommented(let id):
				events.articleCommented(id, actionId: nil)
			case .articleUnliked(let id):
				events.articleUnliked(id, actionId: nil)
			case .articleGoal(let id):
				events.articleGoal(id, actionId: nil)
		}
	}
}

/// The event calls the demo makes, which `PersonyzeEvents` (a navigation's events closure) and
/// `PersonyzeClient` both have.
protocol DemoEvents
{	func setProfile(_ field: String, _ value: String?)
	func productViewed(_ productId: String, actionId: Int?)
	func productAddedToCart(_ productId: String, actionId: Int?, quantity: Int?)
	func productLiked(_ productId: String, actionId: Int?)
	func productPurchased(_ productId: String, actionId: Int?, quantity: Int?)
	func productUnliked(_ productId: String, actionId: Int?)
	func productRemovedFromCart(_ productId: String, actionId: Int?, quantity: Int?)
	func productsPurchased()
	func productsUnliked()
	func productsRemovedFromCart()
	func articleViewed(_ articleId: String, actionId: Int?)
	func articleLiked(_ articleId: String, actionId: Int?)
	func articleCommented(_ articleId: String, actionId: Int?)
	func articleUnliked(_ articleId: String, actionId: Int?)
	func articleGoal(_ articleId: String, actionId: Int?)
}

extension PersonyzeEvents: DemoEvents
{
}

extension PersonyzeClient: DemoEvents
{
}

/// The second screen: events, a navigation, and what Personyze decided.
class DemoViewController: UIViewController
{	private static let userFields = ["Email", "First name", "Last name", "Phone", "Custom"]
	private static let userFieldsInternal = ["email", "first_name", "last_name", "phone", "Custom"]

	@IBOutlet weak var inputNav: MYTextField!
	@IBOutlet weak var buttonNav: UIButton!
	@IBOutlet weak var loading: UIActivityIndicatorView!
	@IBOutlet weak var stackEvents: UIStackView!
	@IBOutlet weak var pickerUserField: MYPickerView!
	@IBOutlet weak var inputUserField: MYTextField!
	@IBOutlet weak var inputUserValue: MYTextField!
	@IBOutlet weak var pickerProductOrArticle: MYPickerView!
	@IBOutlet weak var inputProductId: MYTextField!
	@IBOutlet weak var pickerStatus: MYPickerView!
	@IBOutlet weak var labelEvents: UILabel!
	@IBOutlet weak var labelDemoError: UILabel!
	@IBOutlet weak var tableRes: MYTableView!

	private var events: [Event] = []
	private var result = PersonyzeResult.empty
	private var curAction: PersonyzeAction?
	private var following: Task<Void, Never>?
	private var followingPush: Task<Void, Never>?
	private var pushLine = ""

	override func viewDidLoad()
	{	super.viewDidLoad()
		inputNav.setStorageKey("Nav")
		stackEvents.isHidden = true
		pickerUserField.setOptions(DemoViewController.userFields)
		pickerUserField.setOnChange(changedPickerUserField)
		inputUserValue.setStorageKey("User Field")
		inputUserField.setStorageKey("User Value")
		pickerProductOrArticle.setOptions(["Product", "Article"])
		pickerProductOrArticle.setOnChange(changedPickerProductOrArticle)
		inputProductId.setStorageKey("Product Id")
		changedPickerProductOrArticle(value: 0)
		tableRes.setOnSelect(selectedTableRow)
		updateEventsView()
	}

	/// The decision as it changes - restored from the last run, then updated by every response and
	/// by the action templates as they arrive.
	override func viewWillAppear(_ animated: Bool)
	{	super.viewWillAppear(animated)
		following = Task { [weak self] in
			for await result in Personyze.results
			{	self?.show(result)
			}
		}
		// Where push stands: registered after the first request, and pushed once the account has its Apple key.
		followingPush = Task { [weak self] in
			for await status in Personyze.pushStatuses
			{	self?.pushLine = DemoViewController.pushWords(status)
				if let self
				{	self.show(self.result)
				}
			}
		}
	}

	/// What `PersonyzePushStatus` says, in words.
	private static func pushWords(_ s: PersonyzePushStatus) -> String
	{	guard s.token != nil else
		{	return "push: no token yet"
		}
		guard let visitor = s.registeredVisitorId else
		{	return "push: token, not registered yet"
		}
		return s.pushed ? "push: registered for \(visitor), pushed at once" : "push: registered for \(visitor), no Apple key - checked"
	}

	override func viewDidDisappear(_ animated: Bool)
	{	super.viewDidDisappear(animated)
		following?.cancel()
		following = nil
		followingPush?.cancel()
		followingPush = nil
	}

	@IBAction func clickedNewSession(_ sender: UIButton)
	{	Personyze.startNewSession()
	}

	@IBAction func clickedNav(_ sender: UIButton)
	{	stackEvents.isHidden = false
	}

	@IBAction func clickedUser(_ sender: UIButton)
	{	let n = pickerUserField.getValue()
		let field = n < DemoViewController.userFieldsInternal.count - 1 ? DemoViewController.userFieldsInternal[n] : inputUserField.text ?? ""
		events.append(.profile(field: field, value: inputUserValue.text ?? ""))
		updateEventsView()
	}

	@IBAction func clickedProduct(_ sender: UIButton)
	{	let id = inputProductId.text ?? ""
		if id.isEmpty
		{	return
		}
		let product = pickerProductOrArticle.getValue() == 0
		switch (product, pickerStatus.getValue())
		{	case (true, 0):
				events.append(.productViewed(id))
			case (true, 1):
				events.append(.productAddedToCart(id))
			case (true, 2):
				events.append(.productLiked(id))
			case (true, 3):
				events.append(.productPurchased(id))
			case (true, 4):
				events.append(.productUnliked(id))
			case (true, 5):
				events.append(.productRemovedFromCart(id))
			case (false, 0):
				events.append(.articleViewed(id))
			case (false, 1):
				events.append(.articleCommented(id))
			case (false, 2):
				events.append(.articleLiked(id))
			case (false, 3):
				events.append(.articleGoal(id))
			case (false, 4):
				events.append(.articleUnliked(id))
			default:
				return
		}
		updateEventsView()
	}

	@IBAction func clickedBuy(_ sender: UIButton)
	{	events.append(.productsPurchased)
		updateEventsView()
	}

	@IBAction func clickedEmptyCart(_ sender: UIButton)
	{	events.append(.productsRemovedFromCart)
		updateEventsView()
	}

	@IBAction func clickedUnlike(_ sender: UIButton)
	{	events.append(.productsUnliked)
		updateEventsView()
	}

	@IBAction func clickedCancel(_ sender: UIButton)
	{	stackEvents.isHidden = true
		events = []
		updateEventsView()
	}

	@IBAction func clickedLogEvents(_ sender: UIButton)
	{	send(navigation: nil)
	}

	@IBAction func clickedGo(_ sender: UIButton)
	{	send(navigation: inputNav.text ?? "")
	}

	private func send(navigation document: String?)
	{	stackEvents.isHidden = true
		let queued = events
		events = []
		updateEventsView()
		labelDemoError.text = ""
		buttonNav.isHidden = true
		loading.startAnimating()
		Task {
			let result: PersonyzeResult
			if let document
			{	// One request: the page view, and the events attributed to the new screen.
				result = await Personyze.navigate(document) { events in
					for event in queued
					{	event.send(to: events)
					}
				}
			}
			else
			{	if let client = Personyze.client
				{	for event in queued
					{	event.send(to: client)
					}
				}
				// Sends what is queued, and answers the decision with what the response changed.
				result = await Personyze.refresh()
			}
			buttonNav.isHidden = false
			loading.stopAnimating()
			show(result)
		}
	}

	private func show(_ result: PersonyzeResult)
	{	self.result = result
		if let error = result.error
		{	labelDemoError.text = error.message
		}
		else
		{	let visitor = Personyze.visitor
			let who = visitor.visitorId.map { "Visitor \($0)" + (visitor.userId.map { " (\($0))" } ?? "") } ?? ""
			labelDemoError.text = [who, pushLine].filter { !$0.isEmpty }.joined(separator: " · ")
		}
		var rows: [(String, Bool)] = []
		rows.append(("**\(result.conditions.count) conditions**", false))
		for condition in result.conditions
		{	rows.append((condition.name ?? "Campaign \(condition.id)", false))
		}
		rows.append(("**\(result.actions.count) actions**", false))
		for action in result.actions
		{	rows.append(("\(action.name ?? "Action \(action.id)") (\(action.contentType ?? "loading"))", true))
		}
		tableRes.setRows(rows: rows)
	}

	private func updateEventsView()
	{	inputUserField.isHidden = pickerUserField.getValue() != DemoViewController.userFields.count - 1
		labelEvents.text = "\(events.count) events"
	}

	private func changedPickerUserField(value: Int)
	{	updateEventsView()
	}

	private func changedPickerProductOrArticle(value: Int)
	{	pickerStatus.setOptions(value == 0 ? ["Viewed", "to Cart", "Liked", "Bought", "Unliked", "from Cart"] : ["Viewed", "Commented", "Liked", "Goal", "Unliked"])
	}

	private func selectedTableRow(nRow: Int)
	{	let n = nRow - (2 + result.conditions.count)
		if result.actions.indices.contains(n)
		{	curAction = result.actions[n]
			performSegue(withIdentifier: "toAction", sender: self)
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{	if segue.identifier == "toAction", let destination = segue.destination as? ActionViewController, let curAction
		{	destination.title = curAction.name ?? "Action \(curAction.id)"
			destination.setAction(action: curAction)
		}
	}
}
