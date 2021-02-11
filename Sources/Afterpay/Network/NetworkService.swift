//
//  NetworkService.swift
//  Afterpay
//
//  Created by Nabila Herzegovina on 10/2/21.
//  Copyright © 2021 Afterpay. All rights reserved.
//

import Foundation

// TODO: Implement more network request error
enum DecodeError: Error {
  case unknown
}

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
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = getRequestBody(for: endpoint)
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

  // Encode

  func encode<T>(_ payload: T) -> Data where T: Encodable {
    do {
      return try JSONEncoder().encode(payload)
    } catch {
      fatalError("Enable to encode")
    }
  }

  func getRequestBody(for endpoint: Endpoint) -> Data {
    switch endpoint {
    case .consumerCardConfirm(let payload):
      return encode(payload)
    case .consumerCards(let payload):
      return encode(payload)
    }
  }
}
