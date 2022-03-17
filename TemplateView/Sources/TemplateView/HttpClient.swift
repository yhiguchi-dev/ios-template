//
// Created by Yuki Higuchi on 2022/03/13.
//

import Foundation

struct HttpClient {
  static func send<T: Encodable, R: Decodable>(url: String, requestBody: T?) async throws -> R? {
    let urlRequest = try HttpRequestBuilder.build(url: url, requestBody: requestBody)
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    return try HttpResponseResolver<R>.resolve(code: response.statusCode, data: data)
  }
}

extension URLSession {
  public func data(for request: URLRequest) async throws -> (Data?, HTTPURLResponse) {
    try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<(Data?, HTTPURLResponse), Error>) in
      let dataTask = self.dataTask(with: request) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
        }
        guard let response = response as? HTTPURLResponse else {
          return continuation.resume(throwing: URLError(.badServerResponse))
        }
        continuation.resume(returning: (data, response))
      }
      dataTask.resume()
    }
  }
}

struct HttpRequestBuilder<T: Encodable> {
  static func build(url: String, requestBody: T?) throws -> URLRequest {
    guard let url = URL(string: url) else {
      throw HttpClientError.invalidUrl
    }
    if let requestBody = requestBody {
      var urlRequest = URLRequest(url: url)
      let encoder = JSONEncoder()
      urlRequest.httpBody = try encoder.encode(requestBody)
      return urlRequest
    }
    return URLRequest(url: url)
  }
}

struct HttpResponseResolver<R: Decodable> {
  static func resolve(code: Int, data: Data?) throws -> R? {
    switch code {
    case (200..<299):
      if let data = data {
        let decoder = JSONDecoder()
        let responseBody = try decoder.decode(R.self, from: data)
        return responseBody
      }
      return nil
    case (400..<499):
      if let data = data, let message = String(data: data, encoding: .utf8) {
        throw HttpClientError.clientError(code: code, message: message)
      }
      throw HttpClientError.clientError(code: code)
    case (500..<599):
      if let data = data, let message = String(data: data, encoding: .utf8) {
        throw HttpClientError.serverError(code: code, message: message)
      }
      throw HttpClientError.serverError(code: code)
    default:
      throw HttpClientError.unknownStatusCodeError(code: code)
    }
  }
}

enum HttpClientError: Error {
  case invalidUrl
  case clientError(code: Int, message: String? = nil)
  case serverError(code: Int, message: String? = nil)
  case unknownStatusCodeError(code: Int)
}
