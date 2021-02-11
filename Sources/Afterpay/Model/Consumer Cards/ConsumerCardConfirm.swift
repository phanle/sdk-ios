//
//  ConsumerCardConfirm.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 11/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

struct ConsumerCardConfirmRequest: Encodable {
  let consumerCardToken: String
  let token: String
  let requestId: String
  let xAuthToken: String
  let aggregator: String
}

struct PaymentDetails: Decodable {
  let virtualCard: VirtualCard
}

struct VirtualCard: Decodable {
  let cardType: String
  let cardNumber: String
  let cvc: String
  let expiry: String
}

struct Courier: Decodable {
  let shippedAt: String?
  let name: String?
  let tracking: String?
  let priority: String?
}

struct OrderDetails: Decodable {
  let consumer: Consumer
  let billing: Contact?
  let shipping: Contact?
  let courier: Courier?
  let items: [Item]?
  let discounts: [Discount]?
}

struct ConsumerCardConfirmResponse: Decodable {
  let id: String
  let token: String
  let paymentDetails: PaymentDetails
  let status: String
  let created: String
  let vccExpiry: String
  let originalAmount: Money
  let orderDetails: OrderDetails
}
