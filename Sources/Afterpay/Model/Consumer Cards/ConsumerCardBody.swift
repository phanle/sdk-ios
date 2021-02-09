//
//  ConsumerCardPayload.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 9/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct ConsumerCardRequest: Encodable {
  let aggregator: String
  let amount: Money
  let consumer: Consumer
  let billing: Contact?
  let shipping: Contact
  let items: [Item]?
  let discounts: [Discount]?
  let merchant: Merchant?
  let merchantReference: String?
  let taxAmount: Money
  let shippingAmount: Money
}

public struct ConsumerCardResponse: Decodable {
  let consumerCardToken: String
  let token: String
  let expires: String
  public let redirectCheckoutUrl: URL
}
