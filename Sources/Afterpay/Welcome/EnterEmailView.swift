//
//  EnterEmailView.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 9/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import UIKit

class EnterEmailView: UIView {

  var emailField: UITextField = {
    let field = UITextField()
    field.keyboardType = .emailAddress
    field.textColor = .black
    return field
  }()

  init(continueAction: Selector) {
    super.init(frame: .zero)

    let continueButton = UIButton()
    continueButton.setTitle("Continue", for: .normal)
    continueButton.setTitleColor(.blue, for: .normal)
    continueButton.addTarget(inputViewController, action: continueAction, for: .touchDown)

    let verticalStack = UIStackView()
    verticalStack.axis = .vertical
    verticalStack.alignment = .center
    verticalStack.distribution = .fillEqually
    verticalStack.spacing = 8

    verticalStack.addArrangedSubview(emailField)
    verticalStack.addArrangedSubview(continueButton)

    verticalStack.translatesAutoresizingMaskIntoConstraints = false

    addSubview(verticalStack)

    NSLayoutConstraint.activate([
      verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      verticalStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
    ])
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
