# Afterpay iOS SDK
![Build and Test](https://github.com/ittybittyapps/afterpay-ios/workflows/Build%20and%20Test/badge.svg?branch=master&event=push) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

The Afterpay iOS SDK provides conveniences to make your Afterpay integration experience as smooth and straightforward as possible. We're working on crafting a great framework for developers with easy drop in components to make payments easy for your customers.

# Table of Contents

- [Afterpay iOS SDK](#afterpay-ios-sdk)
- [Table of Contents](#table-of-contents)
- [Integration](#integration)
  - [Requirements](#requirements)
  - [CocoaPods](#cocoapods)
  - [Carthage](#carthage)
  - [Swift Package Manager](#swift-package-manager)
  - [Manual](#manual)
    - [Download](#download)
      - [GitHub Release](#github-release)
      - [Git Submodule](#git-submodule)
    - [Framework Integration](#framework-integration)
- [Features](#features)
  - [Web Checkout](#web-checkout)
- [Getting Started](#getting-started)
  - [Presenting Web Checkout](#presenting-web-checkout)
    - [In code (UIKit)](#in-code-uikit)
    - [In code (SwiftUI)](#in-code-swiftui)
    - [In Interface Builder](#in-interface-builder)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

# Integration

## Requirements

- iOS 12.0+
- Swift 5.0+

## CocoaPods

```
pod 'afterpay-ios', '~> 1.0'
```

## Carthage

```
github "afterpay/afterpay-ios" ~> 1.0
```

## Swift Package Manager

```
dependencies: [
    .package(url: "https://github.com/afterpay/afterpay-ios.git", .upToNextMajor(from: "1.0.0"))
]
```

## Manual

If you prefer not to use any of the supported dependency managers, you can choose to manually integrate the Afterpay SDK into your project.

### Download

#### GitHub Release

Download the [latest release][latest-release] from GitHub and unzip into an `Afterpay` folder in the root of your project.

#### Git Submodule

Add the Afterpay SDK as a git [submodule](https://git-scm.com/docs/git-submodule) by navigating to the root of your project and running the following commands:

```
git submodule add https://github.com/ittybittyapps/afterpay-ios.git Afterpay
cd Afterpay
git checkout 0.0.1
```

### Framework Integration

Now that the project has been added to the `Afterpay` folder in the root of your project, the Afterpay SDK can be added to your project with the following steps:

1. Open the new `Afterpay` folder, and drag `Afterpay.xcodeproj` into the Project Navigator of your application's Xcode project.
2. Select your application project in the Project Navigator to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
3. In the tab bar at the top of that window, open the "General" panel.
4. Click on the `+` button under the "Frameworks, Libraries, and Embedded Content" section.
5. Select the `Afterpay.framework` for your target platform.

And that's it, the Afterpay SDK is now ready to import and use within your application.

# Features

The initial release of the SDK contains the web login and pre approval process with more features to come in subsequent releases.

## Web Checkout

Provided the token generated during the checkout process we take care of pre approval process during which the user will log into Afterpay. The provided integration accounts for cookie storage such that returning customers will only have to re-authenticate with Afterpay once their existing sessions have expired.

# Getting Started

We provide options for integrating via code, interface builder or even SwiftUI

## Presenting Web Checkout

The Web Login is a UIViewController that can be presented in the context of your choosing

### In code (UIKit)

```swift
final class MyViewController: UIViewController {
  // ...
  @objc func didTapPayWithAfterpay {
    let webLoginViewController = AfterpayWebLoginViewController(url: redirectCheckoutUrl)
    present(webLoginViewController, animated: true)
  }
}
```

### In code (SwiftUI)

```swift
struct MyView: View {
  // ...
  var body: some View {
    NavigationView {
      NavigationLink(destination: AfterpayWebLoginView(url: self.redirectCheckoutUrl)) {
        Text("Pay with Afterpay")
      }.buttonStyle(PlainButtonStyle())
    }
  }
}
```

### In Interface Builder

In your storyboard:

In your view controller:

```swift
final class MyViewController: UIViewController {
  // ...
  override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
    if let webLoginViewController = segue.destination as? AfterpayWebLoginViewController {
        webLoginViewController.url = redirectCheckoutUrl
    }
  }
}
```

# Examples

The [example project][example] demonstrates how to include an Afterpay payment flow using our prebuilt UI components.

# Contributing

Contributions are welcome! Please read our [contributing guidelines][contributing].

# License

This project is licensed under the terms of the Apache 2.0 license. See the [LICENSE][license] file for more information.

<!-- Links: -->
[contributing]: CONTRIBUTING.md
[example]: Example
[latest-release]: https://github.com/ittybittyapps/afterpay-ios/releases/latest
[license]: LICENSE
