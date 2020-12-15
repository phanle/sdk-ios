//
//  ExpressCheckoutViewController.swift
//  Afterpay
//
//  Created by Adam Campbell on 23/11/20.
//  Copyright © 2020 Afterpay. All rights reserved.
//

import Foundation
import UIKit
import WebKit

// swiftlint:disable:next colon
final class ExpressCheckoutViewController:
  UIViewController,
  UIAdaptivePresentationControllerDelegate,
  WKNavigationDelegate,
  WKScriptMessageHandler,
  WKUIDelegate
{ // swiftlint:disable:this opening_brace

  private static let bundle = Bundle(for: ExpressCheckoutViewController.self)

  private var checkoutURL: URL?
  private let completion: (_ result: CheckoutResult) -> Void

  private let bootstrapURL: URL = URL(string: "https://afterpay.github.io/sdk-example-server/")!

  private var bootstrapWebView: WKWebView!
  private var checkoutWebView: WKWebView!

  // MARK: Initialization

  init(
    checkoutURL: URL?,
    completion: @escaping (_ result: CheckoutResult
  ) -> Void) {
    self.checkoutURL = checkoutURL
    self.completion = completion

    super.init(nibName: nil, bundle: nil)

    presentationController?.delegate = self

    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .light
    }
  }

  override func loadView() {
    let preferences = WKPreferences()
    preferences.javaScriptEnabled = true
    preferences.javaScriptCanOpenWindowsAutomatically = true

    let userContentController = WKUserContentController()
    userContentController.add(self, name: "nativeApp")

    let configuration = WKWebViewConfiguration()
    configuration.preferences = preferences
    configuration.userContentController = userContentController

    bootstrapWebView = WKWebView(frame: .zero, configuration: configuration)
    bootstrapWebView.translatesAutoresizingMaskIntoConstraints = false
    bootstrapWebView.navigationDelegate = self
    bootstrapWebView.uiDelegate = self

    let view = UIView()

    view.addSubview(bootstrapWebView)

    NSLayoutConstraint.activate([
      bootstrapWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bootstrapWebView.topAnchor.constraint(equalTo: view.topAnchor),
      bootstrapWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bootstrapWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    self.view = view
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let request = URLRequest(url: bootstrapURL)
    bootstrapWebView.load(request)
  }

  // MARK: UIAdaptivePresentationControllerDelegate

  func presentationControllerShouldDismiss(
    _ presentationController: UIPresentationController
  ) -> Bool {
    return false
  }

  // MARK: WKNavigationDelegate

  private let externalLinkPathComponents = ["privacy-policy", "terms-of-service"]

  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    guard
      let url = navigationAction.request.url,
      externalLinkPathComponents.contains(url.lastPathComponent)
    else {
      return decisionHandler(.allow)
    }

    decisionHandler(.cancel)
    UIApplication.shared.open(url)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    guard webView == bootstrapWebView else {
      return
    }

    let urlAppendingIsWindowed = { (url: URL) -> URL in
      var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
      let isWindowed = URLQueryItem(name: "isWindowed", value: "true")
      let queryItems = urlComponents?.queryItems ?? []
      urlComponents?.queryItems = queryItems + [isWindowed]
      return urlComponents?.url ?? url
    }

    let handleCheckoutURLResult = { [weak self] (result: Result<URL, Error>) in
      switch (result, self) {
      case (.success(let url), let strongSelf?):
        let updatedURL = urlAppendingIsWindowed(url)
        strongSelf.checkoutURL = updatedURL
        let javaScript = "openAfterpay('\(updatedURL.absoluteString)');"
        DispatchQueue.main.async { webView.evaluateJavaScript(javaScript) }

      case (.failure, let strongSelf?):
        break

      case (.success, nil), (.failure, nil):
        break
      }
    }

    if let url = checkoutURL {
      handleCheckoutURLResult(.success(url))
    } else {
      getExpressCheckoutHandler()?.didCommenceCheckout(completion: handleCheckoutURLResult)
    }
  }

  func webView(
    _ webView: WKWebView,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    let handled = authenticationChallengeHandler(challenge, completionHandler)

    if handled == false {
      completionHandler(.performDefaultHandling, nil)
    }
  }

  // MARK: WKUIDelegate

  func webView(
    _ webView: WKWebView,
    createWebViewWith configuration: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction,
    windowFeatures: WKWindowFeatures
  ) -> WKWebView? {
    checkoutWebView = WKWebView(frame: view.bounds, configuration: configuration)
    checkoutWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    checkoutWebView.allowsLinkPreview = false
    checkoutWebView.navigationDelegate = self
    view.addSubview(checkoutWebView)

    return checkoutWebView
  }

  // MARK: WKScriptMessageHandler

  typealias Completion = ExpressCheckoutCompletion
  typealias Message = ExpressCheckoutMessage

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    let jsonData = (message.body as? String)?.data(using: .utf8)
    let message = jsonData.flatMap { try? decoder.decode(Message.self, from: $0) }
    let completion = jsonData.flatMap { try? decoder.decode(Completion.self, from: $0) }

    let postMessage = { [encoder, checkoutURL, bootstrapWebView] (message: Message) in
      let data = try? encoder.encode(message)
      let json = data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
      let targetURL = URL(string: "/", relativeTo: checkoutURL)?.absoluteString ?? "*"
      let javascript = "postCheckoutMessage(JSON.parse('\(json)'), '\(targetURL)');"
      bootstrapWebView?.evaluateJavaScript(javascript)
    }

    switch (message, message?.payload, completion) {
    case (let message?, .address(let address), _):
      getExpressCheckoutHandler()?.shippingAddressDidChange(address: address) { options in
        postMessage(.init(requestId: message.requestId, payload: .shippingOptions(options)))
      }

    case(_, .shippingOption(let shippingOption), _):
      getExpressCheckoutHandler()?.shippingOptionDidChange(shippingOption: shippingOption)

    case (_, _, .success(let token)):
      dismiss(animated: true) { self.completion(.success(token: token)) }

    case (_, _, .cancelled):
      dismiss(animated: true) { self.completion(.cancelled(reason: .userInitiated)) }

    default:
      break
    }
  }

  // MARK: Unavailable

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
