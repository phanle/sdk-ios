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