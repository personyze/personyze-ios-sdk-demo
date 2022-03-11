//
//  DemoViewController.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/8/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import UIKit
import WebKit

fileprivate enum Event
{   case userData(field: String, value: String)
    case productViewed(id: String)
	case productAddedToCart(id: String)
	case productLiked(id: String)
	case productPurchased(id: String)
	case productUnliked(id: String)
	case productRemovedFromCart(id: String)
	case productsPurchased
	case productsUnliked
	case productsRemovedFromCart
	case articleViewed(id: String)
	case articleLiked(id: String)
	case articleCommented(id: String)
	case articleUnliked(id: String)
	case articleGoal(id: String)
}

class DemoViewController: UIViewController
{   private static let USER_FIELDS = ["Email", "First name", "Last name", "Phone", "Custom"]
    private static let USER_FIELDS_INTERNAL = ["email", "first_name", "last_name", "phone", "Custom"]

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
    private var trackerResult: PersonyzeResult? = nil
    private var curAction: PersonyzeAction? = nil

    override func viewDidLoad()
    {   super.viewDidLoad()

        inputNav.setStorageKey("Nav")
        stackEvents.isHidden = true
        pickerUserField.setOptions(DemoViewController.USER_FIELDS)
        pickerUserField.setOnChange(changedPickerUserField)
        inputUserValue.setStorageKey("User Field")
        inputUserField.setStorageKey("User Value")
        pickerProductOrArticle.setOptions(["Product", "Article"])
		pickerProductOrArticle.setOnChange(changedPickerProductOrArticle)
        inputProductId.setStorageKey("Product Id")
        pickerStatus.setOptions(["Viewed", "+ to Cart", "+ to Fav", "Bought"])
		tableRes.setOnSelect(selectedTableRow)
        updateEventsView()
        getResult() // current state
    }

    @IBAction func clickedNewSession(_ sender: UIButton)
    {   PersonyzeTracker.inst.startNewSession()
        tableRes.setRows(rows: [])
    }
    
    @IBAction func clickedNav(_ sender: UIButton)
    {   stackEvents.isHidden = false
    }

    @IBAction func clickedUser(_ sender: UIButton)
    {   let nField = pickerUserField.getValue()
        let field = nField < DemoViewController.USER_FIELDS_INTERNAL.count-1 ? DemoViewController.USER_FIELDS_INTERNAL[nField] : inputUserField.text ?? ""
        let value = inputUserValue.text ?? ""
        events.append(.userData(field: field, value: value))
        updateEventsView()
    }

    @IBAction func clickedProduct(_ sender: UIButton)
    {   if let id = inputProductId.text
        {	if !id.isEmpty
			{	enum What {case product; case article}
				let what = pickerProductOrArticle.getValue()==0 ? What.product : What.article
				switch pickerStatus.getValue()
				{	case 0 where what == .product:
						events.append(.productViewed(id: id))
					case 1 where what == .product:
						events.append(.productAddedToCart(id: id))
					case 2 where what == .product:
						events.append(.productLiked(id: id))
					case 3 where what == .product:
						events.append(.productPurchased(id: id))
                    case 4 where what == .product:
                        events.append(.productUnliked(id: id))
                    case 5 where what == .product:
                        events.append(.productRemovedFromCart(id: id))
					case 0 where what == .article:
						events.append(.articleViewed(id: id))
					case 1 where what == .article:
						events.append(.articleCommented(id: id))
					case 2 where what == .article:
						events.append(.articleLiked(id: id))
					case 3 where what == .article:
						events.append(.articleGoal(id: id))
					default:
						return
				}
				updateEventsView()
			}
        }
    }

    @IBAction func clickedBuy(_ sender: UIButton)
    {   events.append(.productsPurchased)
        updateEventsView()
    }

    @IBAction func clickedEmptyCart(_ sender: UIButton)
    {   events.append(.productsRemovedFromCart)
        updateEventsView()
    }

    @IBAction func clickedUnlike(_ sender: UIButton)
    {   events.append(.productsUnliked)
        updateEventsView()
    }

    @IBAction func clickedCancel(_ sender: UIButton)
    {   stackEvents.isHidden = true
        events = []
        updateEventsView()
    }

    @IBAction func clickedLogEvents(_ sender: UIButton)
    {   trackerSend(withNavigation: false)
    }

    @IBAction func clickedGo(_ sender: UIButton)
    {   trackerSend(withNavigation: true)
    }

    private func trackerSend(withNavigation: Bool)
    {   stackEvents.isHidden = true
		// events
		for e in events
		{	switch e
            {   case .userData(let field, let value):
                    PersonyzeTracker.inst.logUserData(field: field, value: value)
                case .productViewed(let id):
					PersonyzeTracker.inst.productViewed(productId: id)
				case .productAddedToCart(let id):
					PersonyzeTracker.inst.productAddedToCart(productId: id)
				case .productLiked(let id):
					PersonyzeTracker.inst.productLiked(productId: id)
				case .productPurchased(let id):
					PersonyzeTracker.inst.productPurchased(productId: id)
				case .productUnliked(let id):
					PersonyzeTracker.inst.productUnliked(productId: id)
				case .productRemovedFromCart(let id):
					PersonyzeTracker.inst.productRemovedFromCart(productId: id)
				case .productsPurchased:
					PersonyzeTracker.inst.productsPurchased()
				case .productsUnliked:
					PersonyzeTracker.inst.productsUnliked()
				case .productsRemovedFromCart:
					PersonyzeTracker.inst.productsRemovedFromCart()
				case .articleViewed(let id):
					PersonyzeTracker.inst.articleViewed(articleId: id)
				case .articleLiked(let id):
					PersonyzeTracker.inst.articleLiked(articleId: id)
				case .articleCommented(let id):
					PersonyzeTracker.inst.articleCommented(articleId: id)
				case .articleUnliked(let id):
					PersonyzeTracker.inst.articleUnliked(articleId: id)
				case .articleGoal(let id):
					PersonyzeTracker.inst.articleGoal(articleId: id)
            }
		}
		events = []
		updateEventsView()
		labelDemoError.text = ""
        tableRes.setRows(rows: [])
        buttonNav.isHidden = true
        loading.startAnimating()
        // load
        if withNavigation
        {   PersonyzeTracker.inst.navigate(documentName: inputNav.text ?? "")
        }
		getResult()
    }
    
    func getResult()
    {   PersonyzeTracker.inst.getResult()
        {    result, error in
            self.buttonNav.isHidden = false
            self.loading.stopAnimating()
            if let error = error
            {    self.labelDemoError.text = error.localizedDescription
            }
            else if let result = result
            {   self.trackerResult = result
                var rows: [(String, Bool)] = []
                rows.append(("**\(result.conditions.count) conditions**", false))
                for item in result.conditions
                {   rows.append((item.name ?? "(Name not detected)", false))
                }
                rows.append(("**\(result.actions.count) actions**", false))
                for item in result.actions
                {   rows.append(((item.name ?? "(Name not detected)") + " (\(item.contentType ?? "unknown"))", true))
                }
                self.tableRes.setRows(rows: rows)
            }
        }
    }

    private func updateEventsView()
    {   inputUserField.isHidden = pickerUserField.getValue() != DemoViewController.USER_FIELDS.count-1
        labelEvents.text = "\(events.count) events"
    }

    private func changedPickerUserField(value: Int)
    {   updateEventsView()
    }

    private func changedPickerProductOrArticle(value: Int)
    {   pickerStatus.setOptions(value == 0 ? ["Viewed", "to Cart", "Liked", "Bought", "Unliked", "from Cart"] : ["Viewd", "Commented", "Liked", "Goal"])
    }

    private func selectedTableRow(nRow: Int)
	{   if let trackerResult = trackerResult
        {   let n = nRow - (2 + trackerResult.conditions.count)
            if n >= 0 && n < trackerResult.actions.count
            {   curAction = trackerResult.actions[n]
                performSegue(withIdentifier: "toAction", sender: self)
            }
        }
	}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {   if segue.identifier == "toAction"
        {   if let destination = segue.destination as? ActionViewController
            {   if let curAction = curAction
                {   destination.title = curAction.name ?? ""
                    destination.setAction(action: curAction)
                }
            }
        }
    }
}
