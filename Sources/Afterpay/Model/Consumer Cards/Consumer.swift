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
    return Consumer(phoneNumber: "917-653-8956", givenNames: "John", surname: "Doe", email: "vigad35147@hrandod.com")
  }
}
