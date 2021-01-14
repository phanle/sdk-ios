//
//  Alerts.swift
//  Afterpay
//
//  Created by Adam Campbell on 22/12/20.
//  Copyright © 2020 Afterpay. All rights reserved.
//

import Foundation
import UIKit

enum Alerts {

  static func failedToLoad(
    retry: @escaping () -> Void,
    cancel: @escaping () -> Void
  ) -> UIAlertController {
    let alert = UIAlertController(
      title: "Error",
      message: "Failed to load Afterpay checkout",
      preferredStyle: .alert
    )

    let retryHandler: (UIAlertAction) -> Void = { _ in retry() }
    let cancelHandler: (UIAlertAction) -> Void = { _ in cancel() }

    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: retryHandler))
    alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: cancelHandler))

    return alert
  }

  static func areYouSureYouWantToCancel(cancel: @escaping () -> Void) -> UIAlertController {
    let actionSheet = UIAlertController(
      title: "Are you sure you want to cancel the payment?",
      message: nil,
      preferredStyle: .actionSheet
    )

    let cancelHandler: (UIAlertAction) -> Void = { _ in cancel() }

    let actions = [
      UIAlertAction(title: "Yes", style: .destructive, handler: cancelHandler),
      UIAlertAction(title: "No", style: .cancel, handler: nil),
    ]

    actions.forEach(actionSheet.addAction)

    return actionSheet
  }

}
