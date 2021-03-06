# Afterpay iOS SDK

![Build and Test][badge-ci]
[![Swift Package Manager compatible][badge-spm]][spm]
[![Carthage compatible][badge-carthage]][carthage]
[![CocoaPods compatible][badge-ccp]][ccp]
![Platform][badge-platform]
![License][badge-license]

The Afterpay iOS SDK provides conveniences to make your Afterpay integration experience as smooth and straightforward as possible. We're working on crafting a great framework for developers with easy drop in components to make payments easy for your customers.

# Table of Contents

- [Afterpay iOS SDK](#afterpay-ios-sdk)
- [Table of Contents](#table-of-contents)
- [Integration](#integration)
  - [Requirements](#requirements)
  - [Swift Package Manager](#swift-package-manager)
  - [Carthage](#carthage)
  - [CocoaPods](#cocoapods)
  - [Manual](#manual)
    - [Source](#source)
      - [GitHub Release](#github-release)
      - [Git Submodule](#git-submodule)
      - [Project / Workspace Integration](#project--workspace-integration)
    - [XCFramework](#xcframework)
- [Features](#features)
  - [Web Checkout](#web-checkout)
    - [Note](#note)
  - [Security](#security)
    - [Swift](#swift)
    - [Objective-C](#objective-c)
  - [Badge](#badge)
  - [Price Breakdown](#price-breakdown)
    - [Accessibility and Dark mode](#accessibility-and-dark-mode)
- [Getting Started](#getting-started)
  - [Presenting Web Checkout](#presenting-web-checkout)
    - [Swift (UIKit)](#swift-uikit)
    - [Objective-C (UIKit)](#objective-c-uikit)
    - [SwiftUI](#swiftui)
- [Examples](#examples)
- [Building](#building)
  - [Mint](#mint)
  - [Running](#running)
  - [XCFramework](#xcframework-1)
- [Contributing](#contributing)
- [License](#license)

# Integration

## Requirements

- iOS 12.0+
- Swift 5.2+
- Xcode 11.4+

## Swift Package Manager

```
dependencies: [
    .package(url: "https://github.com/afterpay/sdk-ios.git", .upToNextMajor(from: "1.0.0"))
]
```

## Carthage

```
github "afterpay/sdk-ios" ~> 1.0
```

## CocoaPods

```
pod 'Afterpay', '~> 1.0'
```

## Manual

If you prefer not to use any of the supported dependency managers, you can choose to manually integrate the Afterpay SDK into your project.

### Source

#### GitHub Release

Download the [latest release][latest-release] source zip from GitHub and unzip into an `Afterpay` directory in the root of your working directory.

#### Git Submodule

Add the Afterpay SDK as a [git submodule][git-submodule] by navigating to the root of your working directory and running the following commands:

```
git submodule add https://github.com/afterpay/sdk-ios.git Afterpay
cd Afterpay
git checkout 1.4.3
```

#### Project / Workspace Integration

Now that the Afterpay SDK resides in the `Afterpay` directory in the root of your working directory, it can be added to your project or workspace with the following steps:

1. Open the new `Afterpay` directory, and drag `Afterpay.xcodeproj` into the Project Navigator of your application's Xcode project or workspace.
2. Select your application project in the Project Navigator to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
3. In the tab bar at the top of that window, open the "General" panel.
4. Click on the `+` button under the "Frameworks, Libraries, and Embedded Content" section.
5. Select the `Afterpay.framework` for your target platform.

And that's it, the Afterpay SDK is now ready to import and use within your application.

### XCFramework

1. Download the [latest release][latest-release] framework zip from GitHub and unzip it. 
2. Select your application project in the Project Navigator to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
3. Drag the `Afterpay.xcframework` under the "Frameworks, Libraries, and Embedded Content" section of your application target in the General tab.

# Features

The Afterpay SDK contains a checkout web flow with optional security features as well some UI components.

## Web Checkout

Provided the URL generated during the checkout process we take care of pre approval process during which the user will log into Afterpay. The provided integration accounts for cookie storage such that returning customers will only have to re-authenticate with Afterpay once their existing sessions have expired.

### Note

These cookies are stored in the default web kit website data store and can be cleared if required by writing code similar to:

```swift
let dataStore = WKWebsiteDataStore.default()
let dataTypes = [WKWebsiteDataTypeCookies] as Set<String>

dataStore.fetchDataRecords(ofTypes: dataTypes) { records in
  let afterpayRecords = records.filter { $0.displayName == "afterpay.com" }
  dataStore.removeData(ofTypes: dataTypes, for: afterpayRecords) {}
}
```

## Security

For added security, a method to hook into the SDKs WKWebView Authentication Challenge Handler is provided. With this you can implement things like SSL Pinning to ensure you can trust your end to end connections. An example of this has been provided in the [example project][example] and in the snippet below using [TrustKit][trust-kit]. In this handler you must return whether or not you have handled the challenge yourself (have called the completionHandler) by returning `true`, or if you wish to fall back to the default handling by returning `false`.

### Swift

```swift
Afterpay.setAuthenticationChallengeHandler { challenge, completionHandler -> Bool in
 let validator = TrustKit.sharedInstance().pinningValidator
 return validator.handle(challenge, completionHandler: completionHandler)
}
```

### Objective-C

```objc
typedef void (^ CompletionHandler)(NSURLSessionAuthChallengeDisposition, NSURLCredential *);

BOOL (^challengeHandler)(NSURLAuthenticationChallenge *, CompletionHandler) = ^BOOL(
 NSURLAuthenticationChallenge *challenge,
 CompletionHandler completionHandler
) {
 TSKPinningValidator *pinningValidator = [[TrustKit sharedInstance] pinningValidator];
 return [pinningValidator handleChallenge:challenge completionHandler:completionHandler];
};

[APAfterpay setAuthenticationChallengeHandler:challengeHandler];
```

## Views

### Color Schemes

Color schemes can be set on the badge view or payment button to either have a single style in both light and dark mode or to change automatically.

```swift
// Always black on mint
badgeView.colorScheme = .static(.blackOnMint)

// White on black in light mode and black on white in dark mode
badgeView.colorScheme = .dynamic(lightPalette: .whiteOnBlack, darkPalette: .blackOnWhite)
```

### Badge

The Afterpay badge is a simple `UIView` that can be scaled to suit the needs of your app. As per branding guidelines it has a minimum width constraint of 64 points.

```swift
let badgeView = BadgeView()
```

Below are examples of the badge in each of the color schemes:  
![Black on Mint badge][badge-black-on-mint] ![Mint on Black badge][badge-mint-on-black] ![White on Black badge][badge-white-on-black] ![Black on White badge][badge-black-on-white]

### Payment Button

The Afterpay Payment Button is a subclass of `UIButton` that can be scaled to suit your layout, to guarantee legibility it has a maximum width constraint of 256 points.

Below are examples of the button in each of the color schemes:
| Mint and Black | Black and White |
| -- | -- |
| ![Black on Mint button][button-black-on-mint] | ![White on Black button][button-white-on-black] | 
| ![Mint on Black button][button-mint-on-black] | ![Black on White button][button-black-on-white] |

## Price Breakdown

The price breakdown component displays information about Afterpay instalments and handles a number of common scenarios.

A configuration should be set on the Afterpay SDK in line with configuration data retrieved from the Afterpay API. This configuration can be cached and should be updated once per day.

A locale should also be set matching the region for which you need to display terms and conditions. This also affects how currencies are localised as well as what branding is displayed, for instance usage of the `"en_GB"` locale will display Clearpay branding.

```swift
do {
  let configuration = try Configuration(
    minimumAmount: response.minimumAmount?.amount,
    maximumAmount: response.maximumAmount.amount,
    currencyCode: response.maximumAmount.currency,
    locale: Locale(identifier: "en_US")
  )

  Afterpay.setConfiguration(configuration)
} catch {
  // Something went wrong
}
```

A total payment amount (represented as a Swift Decimal) must be programatically set on the component to display Afterpay instalment information.

```swift
// A zero here will display the generic 'pay with afterpay' messaging
let totalAmount = Decimal(string: price) ?? .zero

let priceBreakdownView = PriceBreakdownView()
priceBreakdownView.totalAmount = totalAmount
```

After setting the total amount the matching breakdown string for the set Afterpay configuration will be displayed.

For example:  
![Four payments available][four-payments]

### Accessibility and Dark mode

By default this component updates when the trait collection changes to update text and image size as well as colors to match. A components page in the Example app has been provided to demonstrate.

# Getting Started

We provide options for integrating the SDK in Swift and Objective-C.

## Presenting Web Checkout

The Web Login is a `UIViewController` that can be presented modally over the view controller of your choosing.

### Swift (UIKit)

```swift
import Afterpay
import UIKit

final class CheckoutViewController: UIViewController {
  // ...
  @objc func didTapPayWithAfterpay() {
    Afterpay.presentCheckoutModally(over: self, loading: self.checkoutUrl) { result in
      switch result {
      case .success(let token):
        // Handle successful Afterpay checkout
      case .cancelled(let reason):
        // Handle checkout cancellation
      }
    }
  }
}
```

### Objective-C (UIKit)

```objc
#import "ViewController.h"
#import <Afterpay/Afterpay-Swift.h>
#import <UIKit/UIKit.h>

@implementation ViewController

// ...

- (void)didTapPayWithAfterpay {

  void (^completion)(APCheckoutResult *) = ^(APCheckoutResult *result) {

    if ([result isKindOfClass:[APCheckoutResultSuccess class]]) {
      // Handle success with [(APCheckoutResultSuccess *)result token]
    } else {
      // Handle cancellation with [(APCheckoutResultCancelled *)result reason]
    }

  };

  [APAfterpay presentCheckoutModallyOverViewController:self
                                    loadingCheckoutURL:self.checkoutUrl
                                              animated:true
                                            completion:completion];

}

@end
```

### SwiftUI

```swift
struct MyView: View {

  // Updating this state with a retrieved checkout URL will present the afterpay sheet
  @State private var checkoutURL: URL?

  var body: some View {
    SomeView()
      .afterpayCheckout(url: $checkoutURL) { result in
        switch result {
        case .success(let token):
          // Handle successful Afterpay checkout
        case .cancelled(let reason):
          // Handle checkout cancellation
        }
      }
  }

}
```

# Examples

The [example project][example] demonstrates how to include an Afterpay payment flow web experience. This project is powered by the [example server][example-server] which shows a simple example of integration with the Afterpay API.

# Building

## Mint

The Afterpay SDK uses [Mint][mint] to install and run Swift command line packages. This has been pre-compiled and included in the repository under the [`Tools/mint`][mint-directory] directory, meaning it does not need to be installed or managed externally.

> **NOTE:** Mint will automatically download the packages it manages on demand. To speed up the initial build of the SDK, the packages can be downloaded by running the [`Scripts/bootstrap`][bootstrap] script.

## Running

Building and running the project is as simple as cloning the repository, opening [`Afterpay.xcworkspace`][afterpay-workspace] and building the `Afterpay` target. The example project can be built and run via the `Example` target.

## XCFramework

A `.xcframework` can be generated by running the included [`create-xcframework`][create-xcframework].

# Contributing

Contributions are welcome! Please read our [contributing guidelines][contributing].

# License

This project is licensed under the terms of the Apache 2.0 license. See the [LICENSE][license] file for more information.

<!-- Links: -->
[afterpay-workspace]: Afterpay.xcworkspace
[badge-ci]: https://github.com/afterpay/sdk-ios/workflows/Build%20and%20Test/badge.svg?branch=master&event=push
[badge-carthage]: https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat
[badge-ccp]: http://img.shields.io/cocoapods/v/Afterpay.svg?style=flat
[badge-license]: http://img.shields.io/cocoapods/l/Afterpay.svg?style=flat
[badge-platform]: http://img.shields.io/cocoapods/p/Afterpay.svg?style=flat
[badge-spm]: https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat
[badge-black-on-mint]: Images/badge_black_on_mint.png
[badge-mint-on-black]: Images/badge_mint_on_black.png
[badge-white-on-black]: Images/badge_white_on_black.png
[badge-black-on-white]: Images/badge_black_on_white.png
[button-black-on-mint]: Images/button_black_on_mint.png
[button-mint-on-black]: Images/button_mint_on_black.png
[button-white-on-black]: Images/button_white_on_black.png
[button-black-on-white]: Images/button_black_on_white.png
[bootstrap]: Scripts/bootstrap
[carthage]: https://github.com/Carthage/Carthage
[ccp]: https://cocoapods.org/pods/Afterpay
[contributing]: CONTRIBUTING.md
[create-xcframework]: Scripts/create-xcframework
[example]: Example
[example-server]: https://github.com/afterpay/sdk-example-server
[four-payments]: Images/four-payments.png
[git-submodule]: https://git-scm.com/docs/git-submodule
[latest-release]: https://github.com/afterpay/sdk-ios/releases/latest
[license]: LICENSE
[mint]: https://github.com/yonaskolb/Mint
[mint-directory]: Tools/mint
[spm]: https://github.com/apple/swift-package-manager
[trust-kit]: https://github.com/datatheorem/TrustKit
