//
// Created by Yuki Higuchi on 2022/03/13.
//

import Foundation

struct HttpClient {
  static func get<R: Decodable>(url: String) async throws
    -> Response<R>
  {
    let urlRequest = try URLRequestCreator(url: url, method: HttpMethod.GET).create()
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    return try ResponseResolver.resolve(data: data, response: response)
  }

  static func post<T: Encodable, R: Decodable>(url: String, requestBody: T) async throws
    -> Response<R>
  {
    let urlRequest = try URLRequestCreator(url: url, method: HttpMethod.POST).create(
      requestBody: requestBody)
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    return try ResponseResolver.resolve(data: data, response: response)
  }

  static func postNoBody<T: Encodable>(url: String, requestBody: T) async throws
    -> Response<Void>
  {
    let urlRequest = try URLRequestCreator(url: url, method: HttpMethod.POST).create(
      requestBody: requestBody)
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    return try ResponseResolver.resolveNoBody(data: data, response: response)
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

struct URLRequestCreator {
  let url: String
  let method: HttpMethod

  func create() throws -> URLRequest {
    guard let url = URL(string: url) else {
      throw HttpClientError.invalidUrl
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue
    return urlRequest
  }

  func create<T: Encodable>(requestBody: T) throws -> URLRequest {
    var urlRequest = try create()
    let encoder = JSONEncoder()
    urlRequest.httpBody = try encoder.encode(requestBody)
    return urlRequest
  }
}

struct ResponseResolver {

  static func resolve<R: Decodable>(data: Data?, response: HTTPURLResponse) throws -> Response<R> {
    let code = response.statusCode
    switch code {
    case (200..<299):
      guard let data = data else {
        throw HttpClientError.invalidData
      }
      let decoder = JSONDecoder()
      let responseBody = try decoder.decode(R.self, from: data)
      return Response<R>.success(code: code, responseBody: responseBody)
    default:
      return try resolveError(data: data, code: code)
    }
  }

  static func resolveNoBody(data: Data?, response: HTTPURLResponse) throws -> Response<Void> {
    let code = response.statusCode
    switch code {
    case (200..<299):
      return Response<Void>.success(code: code, responseBody: ())
    default:
      return try resolveError(data: data, code: code)
    }
  }

  static func resolveError<R>(data: Data?, code: Int) throws -> Response<R> {
    var message = ""
    if let data = data, let messageValue = String(data: data, encoding: .utf8) {
      message = messageValue
    }
    switch code {
    case (400..<499):
      return Response<R>.clientError(code: code, message: message)
    case (500..<599):
      return Response<R>.serverError(code: code, message: message)
    default:
      throw HttpClientError.unknownStatusCodeError(code: code)
    }
  }
}

enum HttpMethod: String {
  case POST
  case GET
}

enum Response<T> {
  case success(code: Int, responseBody: T)
  case clientError(code: Int, message: String)
  case serverError(code: Int, message: String)

  func isSuccess() -> Bool {
    switch self {
    case .success: return true
    default: return false
    }
  }
  func isClientError() -> Bool {
    switch self {
    case .clientError: return true
    default: return false
    }
  }
  func isServerError() -> Bool {
    switch self {
    case .serverError: return true
    default: return false
    }
  }
}

enum HttpClientError: Error {
  case invalidUrl
  case invalidData
  case unknownStatusCodeError(code: Int)
}
