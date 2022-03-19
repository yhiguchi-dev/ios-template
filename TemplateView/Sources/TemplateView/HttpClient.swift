//
// Created by Yuki Higuchi on 2022/03/13.
//

import Foundation

struct HttpClient {
  static func get<R: Decodable>(url: String) async throws
    -> HttpResponse<R>
  {
    let urlRequest = try urlRequest(url: url, httpMethod: HttpMethod.GET)
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    return try resolve(code: response.statusCode, data: data)
  }

  static func post<T: Encodable, R: Decodable>(url: String, requestBody: T?) async throws
    -> HttpResponse<R>
  {
    let urlRequest = try urlRequest(url: url, httpMethod: HttpMethod.POST, requestBody: requestBody)
    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    return try resolve(code: response.statusCode, data: data)
  }

  static func urlRequest(url: String, httpMethod: HttpMethod) throws -> URLRequest {
    guard let url = URL(string: url) else {
      throw HttpClientError.invalidUrl
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = httpMethod.rawValue
    return urlRequest
  }

  static func urlRequest<T: Encodable>(url: String, httpMethod: HttpMethod, requestBody: T) throws
    -> URLRequest
  {
    var urlRequest = try urlRequest(url: url, httpMethod: httpMethod)
    let encoder = JSONEncoder()
    urlRequest.httpBody = try encoder.encode(requestBody)
    return urlRequest
  }

  static func resolve<R: Decodable>(code: Int, data: Data?) throws -> HttpResponse<R> {
    switch code {
    case (200..<299):
      if R.self == EmptyResponse.self {
        return HttpResponse<R>.noContent(code: code)
      }
      guard let data = data else {
        throw HttpClientError.invalidData
      }
      let decoder = JSONDecoder()
      let responseBody = try decoder.decode(R.self, from: data)
      return HttpResponse<R>.success(code: code, responseBody: responseBody)
    case (400..<499):
      if let data = data, let message = String(data: data, encoding: .utf8) {
        return HttpResponse<R>.clientError(code: code, message: message)
      }
      return HttpResponse<R>.clientError(code: code)
    case (500..<599):
      if let data = data, let message = String(data: data, encoding: .utf8) {
        return HttpResponse<R>.serverError(code: code, message: message)
      }
      return HttpResponse<R>.serverError(code: code)
    default:
      throw HttpClientError.unknownStatusCodeError(code: code)
    }
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

enum HttpMethod: String {
  case POST
  case GET
}

enum HttpResponse<T> {
  case success(code: Int, responseBody: T)
  case noContent(code: Int)
  case clientError(code: Int, message: String = "")
  case serverError(code: Int, message: String = "")

  func isSuccess() -> Bool {
    switch self {
    case .success: return true
    default: return false
    }
  }
  func isNoContent() -> Bool {
    switch self {
    case .noContent: return true
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

struct EmptyResponse: Decodable {
}
