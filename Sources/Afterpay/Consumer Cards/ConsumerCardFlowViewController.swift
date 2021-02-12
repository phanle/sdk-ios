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
    case consumerCard(cardNumber: String)
    case loading
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
  private let consumerCardView: ConsumerCardView
  private let loadingView: UIActivityIndicatorView

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
    consumerCardView = ConsumerCardView(cardNumber: "")
    loadingView = UIActivityIndicatorView()
    loadingView.hidesWhenStopped = false

    if #available(iOS 13.0, *) {
      loadingView.style = .large
    } else {
      loadingView.style = .whiteLarge
    }

    self.checkoutCompletion = checkoutCompletion

    self.consumerCardToken = ""
    self.token = ""
    self.authToken = ""

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    setupSubViews()

    reloadView()
  }

  private func reloadView() {
    var subview: UIView

    switch currentScreen {
    case .welcome:
      subview = welcomeView
    case .amount:
      subview = enterAmountView
    case .consumerCard(let cardNumber):
      loadingView.stopAnimating()
      consumerCardView.updateCardNumber(with: cardNumber)
      subview = consumerCardView
    case .loading:
      loadingView.startAnimating()
      subview = loadingView
    }

    view.bringSubviewToFront(subview)
    updateLayout(with: subview)
  }

  private func setupSubViews() {
    welcomeView.backgroundColor = view.backgroundColor
    enterAmountView.backgroundColor = view.backgroundColor
    consumerCardView.backgroundColor  = view.backgroundColor
    loadingView.backgroundColor = view.backgroundColor

    welcomeView.translatesAutoresizingMaskIntoConstraints = false
    enterAmountView.translatesAutoresizingMaskIntoConstraints = false
    consumerCardView.translatesAutoresizingMaskIntoConstraints = false

    loadingView.frame = view.frame

    view.addSubview(welcomeView)
    view.addSubview(enterAmountView)
    view.addSubview(consumerCardView)
    view.addSubview(loadingView)
  }

  private func updateLayout(with subview: UIView) {
    NSLayoutConstraint.activate([
      subview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      subview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      subview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  @objc private func continueButtonAction() {
    switch currentScreen {
    case .welcome:
      enterAmountView.amountField.text = consumerCardRequest.amount.amount
      currentScreen = .amount
    case .amount:
      let amountValue = enterAmountView.amountField.text ?? "0.00"

      consumerCardRequest.amount = Money(amount: amountValue, currency: consumerCardRequest.amount.currency)
      currentScreen = .loading

      do {
        try callConsumerCardAPI(payload: consumerCardRequest)
      } catch {
        fatalError("\(error.localizedDescription)")
      }

    default:
      return
    }
  }

  // MARK: - Callbacks

  private func cookieChangeCallback(authToken: String) {
    if !authToken.isEmpty {
      self.authToken = authToken
    }
  }

  private func checkoutCompletion(_ result: CheckoutResult) {
    switch result {
    case .success(let token):
      self.callConsumerCardConfirmAPI(checkoutToken: token)

    case .cancelled(let reason):
      print("Need to handle cancelled. Error reason: \(reason)")
    }
  }

  // MARK: - API Calls

  private func callConsumerCardConfirmAPI(checkoutToken: String) {
    let payload = ConsumerCardConfirmRequest(
      consumerCardToken: self.consumerCardToken,
      token: checkoutToken,
      requestId: "",
      xAuthToken: authToken,
      aggregator: "deadbeef"
    )

    loadingView.startAnimating()

    NetworkService.shared.request(endpoint: .consumerCardConfirm(payload)) { [unowned self] (result: Result<ConsumerCardConfirmResponse, Error>) in
      switch result {
      case .success(let response):
        DispatchQueue.main.async {
          self.currentScreen = .consumerCard(cardNumber: response.paymentDetails.virtualCard.cardNumber)
        }
      case .failure(let error):
        fatalError(error.localizedDescription)
      }
    }

    self.navigationController?.popToRootViewController(animated: true)
    self.navigationController?.presentationController?.delegate = .none
  }

  private func callConsumerCardAPI(payload: ConsumerCardRequest) throws {
    NetworkService.shared.request(endpoint: .consumerCards(payload)) { [unowned self] (result: Result<ConsumerCardResponse, Error>) in
      switch result {
      case .success(let response):
        self.consumerCardToken = response.consumerCardToken

        DispatchQueue.main.async {
          let viewControllerToPresent: UIViewController = CheckoutWebViewController(
            checkoutUrl: response.redirectCheckoutUrl,
            consumerCardFlow: true,
            cookieChangeCallback: self.cookieChangeCallback(authToken:),
            completion: checkoutCompletion(_:)
          )

          loadingView.stopAnimating()
          self.navigationController?.show(viewControllerToPresent, sender: self)
        }
      case .failure(let error):
        fatalError(error.localizedDescription)
      }
    }
  }
}
