//
//  Item.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct Item: Codable {
  let name: String?
  let sku: String
  let quantity: Int?
  let pageUrl: URL
  let imageUrl: URL?
  let price: Money
  let categories: [[String]]?

  static func mock() -> Item {
    return Item(name: "Apple", sku: "Apple123", quantity: 1, pageUrl: URL(string: "https://www.apple.com/")!, imageUrl: nil, price: Money.mock(), categories: nil)
  }
}
