//
// Created by Yuki Higuchi on 2022/03/18.
//

import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

@testable import TemplateView

final class HttpClientTest: XCTestCase {
  override func tearDown() {
    HTTPStubs.removeAllStubs()
  }

  func testPostWithOk() async throws {
    stubPostWithOk()
    let response: HttpResponse<Response> = try await HttpClient.post(
      url: "http://localhost", requestBody: Request(value: "123"))
    XCTAssertEqual(response.isSuccess(), true)
    if case .success(let code, let responseBody) = response {
      XCTAssertEqual(code, 200)
      XCTAssertEqual(responseBody.value, "test")
    }
  }

  func testPostWithNoContent() async throws {
    stubPostWithNoContent()
    let response: HttpResponse<EmptyResponse> = try await HttpClient.post(
      url: "http://localhost", requestBody: Request(value: "123"))
    XCTAssertEqual(response.isNoContent(), true)
    if case .noContent(let code) = response {
      XCTAssertEqual(code, 200)
    }
  }

  func testPostWithBadRequest() async throws {
    stubPostWithBadRequest()
    let response: HttpResponse<EmptyResponse> = try await HttpClient.post(
      url: "http://localhost", requestBody: Request(value: "123"))
    XCTAssertEqual(response.isClientError(), true)
    if case .clientError(let code, let message) = response {
      XCTAssertEqual(code, 400)
      XCTAssertEqual(
        message,
        """
        {
          "error": "invalid"
        }
        """)
    }
  }

  func testGetWithOk() async throws {
    stubGetWithOk()
    let response: HttpResponse<Response> = try await HttpClient.get(
      url: "http://localhost")
    XCTAssertEqual(response.isSuccess(), true)
    if case .success(let code, let responseBody) = response {
      XCTAssertEqual(code, 200)
      XCTAssertEqual(responseBody.value, "test")
    }
  }

  func testGetWithNoContent() async throws {
    stubGetWithNoContent()
    let response: HttpResponse<EmptyResponse> = try await HttpClient.get(
      url: "http://localhost")
    XCTAssertEqual(response.isNoContent(), true)
    if case .noContent(let code) = response {
      XCTAssertEqual(code, 200)
    }
  }

  func testGetWithBadRequest() async throws {
    stubGetWithBadRequest()
    let response: HttpResponse<EmptyResponse> = try await HttpClient.get(
      url: "http://localhost")
    XCTAssertEqual(response.isClientError(), true)
    if case .clientError(let code, let message) = response {
      XCTAssertEqual(code, 400)
      XCTAssertEqual(
        message,
        """
        {
          "error": "invalid"
        }
        """)
    }
  }
}

struct Request: Codable {
  let value: String
}

struct Response: Codable {
  let value: String
}

extension HttpClientTest {
  @discardableResult
  func stubPostWithOk() -> HTTPStubsDescriptor {
    stub(condition: isHost("localhost") && isMethodPOST()) { _ in
      let data = """
        {
          "value": "test"
        }
        """.data(using: .utf8)
      return HTTPStubsResponse(
        data: data!, statusCode: 200, headers: ["Content-Type": "application/json"])
    }
  }

  @discardableResult
  func stubPostWithNoContent() -> HTTPStubsDescriptor {
    stub(condition: isHost("localhost") && isMethodPOST()) { _ in
      HTTPStubsResponse(
        data: "".data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"]
      )
    }
  }

  @discardableResult
  func stubPostWithBadRequest() -> HTTPStubsDescriptor {
    stub(condition: isHost("localhost") && isMethodPOST()) { _ in
      let data = """
        {
          "error": "invalid"
        }
        """.data(using: .utf8)
      return HTTPStubsResponse(
        data: data!, statusCode: 400, headers: ["Content-Type": "application/json"]
      )
    }
  }

  @discardableResult
  func stubGetWithOk() -> HTTPStubsDescriptor {
    stub(condition: isHost("localhost") && isMethodGET()) { _ in
      let data = """
        {
          "value": "test"
        }
        """.data(using: .utf8)
      return HTTPStubsResponse(
        data: data!, statusCode: 200, headers: ["Content-Type": "application/json"])
    }
  }

  @discardableResult
  func stubGetWithNoContent() -> HTTPStubsDescriptor {
    stub(condition: isHost("localhost") && isMethodGET()) { _ in
      HTTPStubsResponse(
        data: "".data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"]
      )
    }
  }

  @discardableResult
  func stubGetWithBadRequest() -> HTTPStubsDescriptor {
    stub(condition: isHost("localhost") && isMethodGET()) { _ in
      let data = """
        {
          "error": "invalid"
        }
        """.data(using: .utf8)
      return HTTPStubsResponse(
        data: data!, statusCode: 400, headers: ["Content-Type": "application/json"]
      )
    }
  }
}
