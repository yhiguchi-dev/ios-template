//
// Created by Yuki Higuchi on 2022/03/13.
//

import Foundation

struct HttpClient {

  func send<R: Decodable>(request: URLRequest) async throws -> R? {
    let (data, response) = try await URLSession.shared.data(for: request)
    switch try HttpStatus.of(code: response.statusCode) {
    case .Successful:
      if let data = data {
        let decoder = JSONDecoder()
        let responseBody = try decoder.decode(R.self, from: data)
        return responseBody
      }
      return nil
    case .ClientError, .ServerError:
      return nil
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
