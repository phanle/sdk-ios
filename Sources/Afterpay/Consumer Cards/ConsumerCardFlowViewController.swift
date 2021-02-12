//
//  ConsumerCardFlowViewController.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 9/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import UIKit

final class ConsumerCardFlowViewController: UIViewController {

  enum Screen {
    case welcome
    case amount
  }

  // View State
  private var currentScreen: Screen = .welcome {
    didSet {
      reloadView()
    }
  }

  // Payload for consumer cards API request
  private var consumerCardRequest: ConsumerCardRequest

  private let checkoutCompletion: (_ result: ConsumerCardCheckoutResult) -> Void

  private let welcomeView: WelcomeView
  private let enterAmountView: EnterAmountView

  private var consumerCardToken: String
  private var token: String
  private var authToken: String

  init(
    with payload: ConsumerCardRequest,
    checkoutCompletion: @escaping (_ result: ConsumerCardCheckoutResult) -> Void
  ) {
    // Validate parameters value

    self.consumerCardRequest = payload

    // initiate views
    welcomeView = WelcomeView(continueAction: #selector(continueButtonAction))
    enterAmountView = EnterAmountView(continueAction: #selector(continueButtonAction))

    self.checkoutCompletion = checkoutCompletion

    self.consumerCardToken = ""
    self.token = ""
    self.authToken = ""

    super.init(nibName: nil, bundle: nil)
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
    }

    view.bringSubviewToFront(subview)
    updateLayout(with: subview)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    welcomeView.backgroundColor = view.backgroundColor
    enterAmountView.backgroundColor = view.backgroundColor

    welcomeView.translatesAutoresizingMaskIntoConstraints = false
    enterAmountView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(welcomeView)
    view.addSubview(enterAmountView)

    reloadView()
  }

  @objc func continueButtonAction() {
    switch currentScreen {
    case .welcome:
      enterAmountView.amountField.text = consumerCardRequest.amount.amount
      currentScreen = .amount
    case .amount:
      let amountValue = enterAmountView.amountField.text ?? "0.00"

      consumerCardRequest.amount = Money(amount: amountValue, currency: consumerCardRequest.amount.currency)
      // call consumer card api
      do {
        try callConsumerCardAPI(payload: consumerCardRequest)
      } catch {
        fatalError("\(error.localizedDescription)")
      }
    }
  }

  // callback for cookie change
  func cookieChangeCallback(authToken: String) {
    self.authToken = authToken

  }

  // Move this func away from view controller
  private func callConsumerCardAPI(payload: ConsumerCardRequest) throws {
    NetworkService.shared.request(endpoint: .consumerCards(payload)) { (result: Result<ConsumerCardResponse, Error>) in
      switch result {
      case .success(let response):
        self.token = response.token
        self.consumerCardToken = response.consumerCardToken
        DispatchQueue.main.async {
          let viewControllerToPresent: UIViewController = CheckoutWebViewController(
            checkoutUrl: response.redirectCheckoutUrl,
            cookieChangeCallback: self.cookieChangeCallback(authToken:),
            completion: { result in
              switch result {
              case .success(let token):
                let bodyRequest = ConsumerCardConfirmRequest(consumerCardToken: self.consumerCardToken,
                        token: token,
                        requestId: "",
                        xAuthToken: self.authToken,
                        aggregator: "deadbeef")

                NetworkService.shared.request(endpoint: .consumerCardConfirm(bodyRequest)) { (result: Result<ConsumerCardConfirmResponse, Error>) in
                  switch result {
                  case .success(let response):
                    DispatchQueue.main.async {
                      let viewControllerToPresent: UIViewController = ConsumerCardViewController(cardNumber: response.paymentDetails.virtualCard.cardNumber)
                      self.navigationController?.show(viewControllerToPresent, sender: self)
                    }
                  case .failure(let error):
                    fatalError(error.localizedDescription)
                  }
                }
                // need authToken
              case .cancelled(let reason):
                print("Need to handle cancelled")
              }
            }
          )

          self.navigationController?.show(viewControllerToPresent, sender: self)
        }
      case .failure(let error):
        fatalError(error.localizedDescription)
      }
    }
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
