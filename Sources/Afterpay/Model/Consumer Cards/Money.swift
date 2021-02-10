//
//  Money.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct Money: Encodable {
  let amount: String
  let currency: String

  public static func mock() -> Self {
    return Money(amount: "35.00", currency: "USD")
  }
}

public struct Discount: Encodable {
  let displayName: String
  let amount: Money
}
