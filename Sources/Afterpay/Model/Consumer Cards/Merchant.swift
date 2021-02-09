//
//  Merchant.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct Merchant: Encodable {
  let redirectConfirmUrl: String
  let redirectCancelUrl: String
  let name: String?
}
