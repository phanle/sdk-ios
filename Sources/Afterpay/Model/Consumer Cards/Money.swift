//
//  Money.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct Money: Codable {
  let amount: String
  let currency: String

  public static func mock() -> Self {
    return Money(amount: "35.00", currency: "USD")
  }
}

public struct Discount: Codable {
  let displayName: String
  let amount: Money
}
