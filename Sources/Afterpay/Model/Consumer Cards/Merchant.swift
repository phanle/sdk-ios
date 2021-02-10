//
//  Merchant.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct Merchant: Encodable {
  let redirectConfirmUrl: URL
  let redirectCancelUrl: URL
  let name: String?

  static func mock() -> Merchant {
    return Merchant(redirectConfirmUrl: URL(string: "https://www.apple.com/")!, redirectCancelUrl: URL(string: "https://www.apple.com/")!, name: "Apple")
  }
}
