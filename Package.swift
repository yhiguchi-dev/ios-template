// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Tools",
  dependencies: [
    .package(url: "https://github.com/apple/swift-format", revision: "0.50500.0"),
    .package(url: "https://github.com/XCTestHTMLReport/XCTestHTMLReport.git", revision: "2.2.1"),
  ]
)
