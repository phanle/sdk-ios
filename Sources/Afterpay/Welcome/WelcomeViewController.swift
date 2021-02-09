//
//  WelcomeViewController.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 9/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import UIKit

final class WelcomeViewController: UIViewController {

  enum Screen {
    case welcome
    case amount
    case email
  }

  // View State
  private var currentScreen: Screen = .welcome {
    didSet {
      reloadView()
    }
  }

  // To be filled by merchant
  private let aggregator: String
  private let billing: Contact?
  private let shipping: Contact
  private let items: [Item]?
  private let discounts: [Discount]?
  private let merchant: Merchant?
  private let merchantReference: String?
  private let taxAmount: Money
  private let shippingAmount: Money

  // To be filled by users
  private var consumer: Consumer
  private var amount: Money // Use tax/shipping currency

  // list of all views
  private let welcomeView: WelcomeView
  private let enterAmountView: EnterAmountView
  private let enterEmailView: EnterEmailView

  init(
    aggregator: String,
    billing: Contact?,
    shipping: Contact,
    items: [Item]?,
    discounts: [Discount]?,
    merchant: Merchant?,
    merchantReference: String?,
    taxAmount: Money,
    shippingAmount: Money,
    consumerEmail: String
  ) {
    // Validate parameters value here

    // Assign parameters
    self.aggregator = aggregator
    self.billing = billing
    self.shipping = shipping
    self.items = items
    self.discounts = discounts
    self.merchant = merchant
    self.merchantReference = merchantReference
    self.taxAmount = taxAmount
    self.shippingAmount = shippingAmount

    self.amount = Money(amount: "0.00", currency: taxAmount.currency)
    self.consumer = Consumer(phoneNumber: nil, givenNames: nil, surname: nil, email: consumerEmail)

    // initiate views
    welcomeView = WelcomeView(continueAction: #selector(updateView))
    enterAmountView = EnterAmountView(continueAction: #selector(updateView))
    enterEmailView = EnterEmailView(continueAction: #selector(updateView))

    super.init(nibName: nil, bundle: nil)

    // update amount when there are items
    if let items = items {
      self.amount = getTotalAmount(with: items, currency: taxAmount.currency)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func reloadView() {
    var subview: UIView
    switch currentScreen {
    case .welcome:
      subview = welcomeView
    case .amount:
      subview = enterAmountView
    case .email:
      subview = enterEmailView
    }

    view.bringSubviewToFront(subview)
    updateLayout(with: subview)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    welcomeView.backgroundColor = view.backgroundColor
    enterEmailView.backgroundColor = view.backgroundColor
    enterAmountView.backgroundColor = view.backgroundColor

    welcomeView.translatesAutoresizingMaskIntoConstraints = false
    enterEmailView.translatesAutoresizingMaskIntoConstraints = false
    enterAmountView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(welcomeView)
    view.addSubview(enterEmailView)
    view.addSubview(enterAmountView)

    reloadView()
  }

  @objc func updateView() {
    switch currentScreen {
    case .welcome:
      enterAmountView.amountField.text = amount.amount
      currentScreen = .amount
    case .amount:
      let amountValue = enterAmountView.amountField.text ?? "0.00"

      amount = Money(amount: amountValue, currency: taxAmount.currency)
      enterEmailView.emailField.text = consumer.email
      currentScreen = .email
    case .email:
      let emailValue = enterEmailView.emailField.text ?? consumer.email
      consumer = Consumer(phoneNumber: nil, givenNames: nil, surname: nil, email: emailValue)
      // perform checkout here
      dismiss(animated: true, completion: nil)
    }
  }

  // Use configuration currency code instead!
  private func getTotalAmount(with items: [Item]?, currency: String) -> Money {
    guard let items = items else {
      return Money(amount: "0.00", currency: currency)
    }

    let totalAmount = items
      .map { item in Decimal(item.quantity) * Decimal(string: item.price.amount)!}
      .reduce(0, +)

    // Use CurrencyFormatter instead
    return Money(amount: "\(totalAmount)", currency: currency)
  }

  private func updateLayout(with subview: UIView) {
    NSLayoutConstraint.activate([
      subview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      subview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      subview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
}
