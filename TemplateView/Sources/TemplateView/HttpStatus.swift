//
// Created by Yuki Higuchi on 2022/03/14.
//

import Foundation

enum HttpStatus {
  case Successful
  case ClientError
  case ServerError

  static func of(code: Int) throws -> HttpStatus {
    switch code {
    case (200..<299): return Successful
    case (400..<499): return ClientError
    case (500..<599): return ServerError
    default: throw HttpStatusError.unknownStatusCode
    }
  }
}

enum HttpStatusError: Error {
  case unknownStatusCode
}
