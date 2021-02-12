//
//  Courrier.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 12/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

struct Courier: Decodable {
  let shippedAt: String?
  let name: String?
  let tracking: String?
  let priority: String?
}
