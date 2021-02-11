//
//  ConsumerCardViewController.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 12/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation
import UIKit

final class ConsumerCardViewController: UIViewController {

  private let consumerCardView: ConsumerCardView

  init(cardNumber: String) {
    self.consumerCardView = ConsumerCardView(cardNumber: cardNumber)

    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view = consumerCardView
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
