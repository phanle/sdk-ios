//
//  Consumer.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct Consumer: Encodable {
  let phoneNumber: String?
  let givenNames: String?
  let surname: String?
  let email: String

  static func mock() -> Consumer {
    return Consumer(phoneNumber: "1234", givenNames: "John", surname: "Doe", email: "test@afterpay.com")
  }
}