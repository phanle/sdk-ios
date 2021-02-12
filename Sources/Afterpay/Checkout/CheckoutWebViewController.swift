//
//  WebLoginViewController.swift
//  Afterpay
//
//  Created by Adam Campbell on 3/6/20.
//  Copyright © 2020 Afterpay. All rights reserved.
//

import UIKit
import WebKit

// swiftlint:disable:next colon
final class CheckoutWebViewController:
  UIViewController,
  UIAdaptivePresentationControllerDelegate,
  WKNavigationDelegate,
  WKHTTPCookieStoreObserver
{ // swiftlint:disable:this opening_brace

  private static let bundle = Bundle(for: CheckoutWebViewController.self)

  private let checkoutUrl: URL
  private let completion: (_ result: CheckoutResult) -> Void
  private let validHosts: Set<String> = [
    "portal.afterpay.com",
    "portal.sandbox.afterpay.com",
    "portal.clearpay.co.uk",
    "portal.sandbox.clearpay.co.uk",
  ]

  private var webView: WKWebView { view as! WKWebView }

  private var token: String = ""

  private let cookieChangeCallback: (_ token: String) -> Void

  // MARK: Initialization

  init(
    checkoutUrl: URL,
    cookieChangeCallback: @escaping (_ token: String) -> Void = { _ in return },
    completion: @escaping (_ result: CheckoutResult) -> Void
  ) {
    self.checkoutUrl = checkoutUrl
    self.completion = completion
    self.cookieChangeCallback = cookieChangeCallback

    super.init(nibName: nil, bundle: nil)
  }

  override func loadView() {
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore.httpCookieStore.add(self)

    view = WKWebView(frame: .zero, configuration: configuration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .light
    } else {
      navigationItem.rightBarButtonItem = UIBarButtonItem(
        title: "Cancel",
        style: .plain,
        target: self,
        action: #selector(presentCancelConfirmation)
      )
    }

    presentationController?.delegate = self

    webView.allowsLinkPreview = false
    webView.navigationDelegate = self
    webView.scrollView.bounces = false
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    guard
      let host = URLComponents(url: checkoutUrl, resolvingAgainstBaseURL: false)?.host,
      validHosts.contains(host)
    else {
      return dismiss(animated: true) { [completion, checkoutUrl] in
        completion(.cancelled(reason: .invalidURL(checkoutUrl)))
      }
    }

    var request = URLRequest(url: checkoutUrl)

    let shortVersionString = Self.bundle.infoDictionary?["CFBundleShortVersionString"] as? String
    let value = shortVersionString.map { version in "\(version)-ios" }
    request.setValue(value, forHTTPHeaderField: "X-Afterpay-SDK")

    webView.load(request)
  }

  // MARK: UIAdaptivePresentationControllerDelegate

  func presentationControllerShouldDismiss(
    _ presentationController: UIPresentationController
  ) -> Bool {
    presentCancelConfirmation()

    return false
  }

  // MARK: Actions

  @objc private func presentCancelConfirmation() {
    let actionSheet = UIAlertController(
      title: "Are you sure you want to cancel the payment?",
      message: nil,
      preferredStyle: .actionSheet
    )

    let cancelPayment: (UIAlertAction) -> Void = { _ in
      self.dismiss(animated: true) { self.completion(.cancelled(reason: .userInitiated)) }
    }

    let actions = [
      UIAlertAction(title: "Yes", style: .destructive, handler: cancelPayment),
      UIAlertAction(title: "No", style: .cancel, handler: nil),
    ]

    actions.forEach(actionSheet.addAction)

    present(actionSheet, animated: true, completion: nil)
  }

  // MARK: WKNavigationDelegate

  private enum Completion {
    case success(token: String)
    case cancelled

    init?(url: URL) {
      let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
      let statusItem = queryItems?.first { $0.name == "status" }
      let orderTokenItem = queryItems?.first { $0.name == "orderToken" }

      switch (statusItem?.value, orderTokenItem?.value) {
      case ("SUCCESS", let token?):
        self = .success(token: token)
      case ("CANCELLED", _):
        self = .cancelled
      default:
        return nil
      }
    }
  }

  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    guard let url = navigationAction.request.url else {
      return decisionHandler(.allow)
    }

    let shouldOpenExternally = navigationAction.targetFrame == nil

    switch (shouldOpenExternally, Completion(url: url)) {
    case (true, _):
      decisionHandler(.cancel)
      UIApplication.shared.open(url)

    case (false, .success(let token)):
      decisionHandler(.cancel)
      self.completion(.success(token: token))
//      dismiss(animated: true) { self.completion(.success(token: token)) }

    case (false, .cancelled):
      decisionHandler(.cancel)
      dismiss(animated: true) { self.completion(.cancelled(reason: .userInitiated)) }

    case (false, nil):
      decisionHandler(.allow)
    }
  }

  func webView(
    _ webView: WKWebView,
    didFailProvisionalNavigation navigation: WKNavigation!,
    withError error: Error
  ) {
    let alert = UIAlertController(
      title: "Error",
      message: "Failed to load Afterpay checkout",
      preferredStyle: .alert)

    let retryHandler: (UIAlertAction) -> Void = { [checkoutUrl] _ in
      webView.load(URLRequest(url: checkoutUrl))
    }

    let cancelHandler: (UIAlertAction) -> Void = { _ in
      self.dismiss(animated: true) { self.completion(.cancelled(reason: .networkError(error))) }
    }

    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: retryHandler))
    alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: cancelHandler))

    present(alert, animated: true, completion: nil)
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

  // MARK: WKHTTPCookieStoreObserver

  func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
    cookieStore.getAllCookies { [weak self] cookies in
      let authCookie = cookies.first { ($0.name == "pl_status" && $0.domain == "portalapi.us-sandbox.afterpay.com") }
      guard let cookie = authCookie else {
        return
      }

      self?.cookieChangeCallback(cookie.value)
    }
  }

  // MARK: Unavailable

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
