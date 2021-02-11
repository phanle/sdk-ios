//
//  ConsumerCard.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 9/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct ConsumerCardRequest: Encodable {
  let aggregator: String
  var amount: Money
  let consumer: Consumer
  let billing: Contact?
  let shipping: Contact
  let items: [Item]?
  let discounts: [Discount]?
  let merchant: Merchant
  let merchantReference: String?
  let taxAmount: Money?
  let shippingAmount: Money?

  public static func mock() -> ConsumerCardRequest {
    return ConsumerCardRequest(
      aggregator: "deadbeef",
      amount: Money.mock(),
      consumer: Consumer.mock(),
      billing: Contact.mock(),
      shipping: Contact.mock(),
      items: [Item.mock()],
      discounts: nil,
      merchant: Merchant.mock(),
      merchantReference: nil,
      taxAmount: nil,
      shippingAmount: nil
    )
  }
}

public struct ConsumerCardResponse: Decodable {
  let consumerCardToken: String
  let token: String
  let expires: String
  public let redirectCheckoutUrl: URL
}
