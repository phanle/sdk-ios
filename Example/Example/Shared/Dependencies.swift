//
//  Dependencies.swift
//  Example
//
//  Created by Adam Campbell on 22/7/20.
//  Copyright © 2020 Afterpay. All rights reserved.
//

import Afterpay
import CommonCrypto
import Foundation
import os.log
import TrustKit

private final class ExpressCheckoutHandler: Afterpay.ExpressCheckoutHandler {

  func didCommenceCheckout(callback: @escaping (URL) -> Void) {}

  func shippingAddressDidChange(address: Address, callback: @escaping ([ShippingOption]) -> Void) {
    let standard = ShippingOption(
      id: "standard",
      name: "Standard",
      description: "3 - 5 days",
      shippingAmount: Money(amount: "0.00", currency: "AUD"),
      orderAmount: Money(amount: "50.00", currency: "AUD")
    )

    let priority = ShippingOption(
      id: "priority",
      name: "Priority",
      description: "Next business day",
      shippingAmount: Money(amount: "10.00", currency: "AUD"),
      orderAmount: Money(amount: "60.00", currency: "AUD")
    )

    callback([standard, priority])
  }

  func shippingOptionDidChange(shippingOption: ShippingOption) {}

}

private let checkoutHandler = ExpressCheckoutHandler()

func initializeDependencies() {
  // In a real world scenario this would be a real backup hash but for demonstration purposes
  // it is an empty hash to satisfy TrustKit's requirements
  let backupHash = Data(count: Int(CC_SHA256_DIGEST_LENGTH)).base64EncodedString()

  let configuration: [String: Any] = [
    kTSKSwizzleNetworkDelegates: false,
    kTSKPinnedDomains: [
      "portal.afterpay.com": [
        kTSKExpirationDate: "2022-06-25",
        kTSKPublicKeyHashes: ["nQ1Tu17lpJ/Hsr3545eCkig+X9ZPcxRQoe5WMSyyqJI=", backupHash],
      ],
      "portal.sandbox.afterpay.com": [
        kTSKExpirationDate: "2021-09-09",
        kTSKPublicKeyHashes: [
          "15mVY9KpcF6J/UzKCS2AfUjUWPVsIvxi9PW0XuFnvH4=",
          "TwuRz37J8epX4J1HDkoli34/3Woh7153cD3x9PFuh6I=",
          "QZBwTzn7tvkZfQE0yflBHXNC8E/5g/Yy9dP3PJZwYss=",
        ],
      ],
    ],
  ]

  TrustKit.initSharedInstance(withConfiguration: configuration)

  Afterpay.setExpressCheckoutHandler(checkoutHandler)

  // Pin Afterpay's payment portal certificates using TrustKit
  Afterpay.setAuthenticationChallengeHandler { challenge, completionHandler -> Bool in
    let validator = TrustKit.sharedInstance().pinningValidator
    return validator.handle(challenge, completionHandler: completionHandler)
  }

  // Configure the Afterpay SDK with the merchant configuration
  Repository.shared.fetchConfiguration { result in
    switch result {
    case .success(let configuration):
      Afterpay.setConfiguration(configuration)
    case .failure(let error):
      // Logs network, decoding and Afterpay configuration errors raised
      let errorDescription = error.localizedDescription
      os_log(.error, "Failed to set configuration with error: %{public}@", errorDescription)
    }
  }
}
