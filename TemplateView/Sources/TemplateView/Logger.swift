//
// Created by Yuki Higuchi on 2022/04/12.
//

import Foundation
import os

struct MyLogger {

  private static let logger: Loggable = {
    let buildType = BuildType.type()
    switch BuildType.type() {
    case .debug:
      return StandardLogger()
    case .release:
      return CrashlyticsLogger()
    }
  }()

  static func info(message: String) {
    logger.info(message: message)
  }

}

enum BuildType {
  case debug
  case release

  static func type() -> BuildType {
    #if DEBUG
      return .debug
    #else
      return .release
    #endif
  }
}

protocol Loggable {
  func info(message: String)
}

struct CrashlyticsLogger: Loggable {
  func info(message: String) {

  }
}

struct StandardLogger: Loggable {
  let logger = Logger(subsystem: "com.flyingalpaca.sample", category: "Network")
  func info(message: String) {
  }
}
