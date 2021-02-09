//
//  Contact.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

public struct Contact: Encodable {
  var name: String
  var line1: String
  var area1: String?
  var region: String
  var postcode: String
  var countryCode: String
  var phoneNumber: String?

  public static func mock() -> Self {
    return Contact(name: "Joe Consumer", line1: "1004 Point Lobos Ave", area1: "San Francisco", region: "CA", postcode: "94121", countryCode: "US", phoneNumber: "2120000000")
  }
}
