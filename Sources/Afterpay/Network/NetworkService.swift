//
//  NetworkService.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

final class NetworkService {

  private let session = URLSession(configuration: .default)

  public static let shared = NetworkService()

  func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {

    // Construct the URL
    var urlComponent = URLComponents(string: endpoint.baseURL)
    urlComponent?.path = endpoint.path

    guard let url = urlComponent?.url else {
      fatalError("Unable to construct URL with \(String(describing: urlComponent?.url))")
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = endpoint.method.rawValue

    if endpoint.method == .post {
      switch endpoint {
      case .consumerCards(let payload):
        do {
          urlRequest.httpBody = try JSONEncoder().encode(payload)
        } catch {
          fatalError("Enable to encode \(payload)")
        }
      }
    }

    session.dataTask(with: urlRequest) { data, _, error in
      if let data = data, error == nil {
        do {
          let response = try JSONDecoder().decode(T.self, from: data)
          completion(.success(response))
        } catch {
          completion(.failure(DecodeError.unknown))
        }
      } else if let error = error {
        completion(.failure(error))
      }
    }.resume()
  }
}

enum DecodeError: Error {
  case unknown
}

enum RequestMethod: String {
  case get = "GET"
  case post = "POST"
}

enum Endpoint {
  case consumerCards(ConsumerCardRequest)
}

extension Endpoint {
  var baseURL: String {
    return "https://api-plus.us-sandbox.afterpay.com"
  }

  var path: String {
    switch self {
    case .consumerCards:
      return "/v2/consumer_cards"
    }
  }

  var method: RequestMethod {
    switch self {
    case .consumerCards:
      return .post
    }
  }
}
