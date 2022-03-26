//
// Created by Yuki Higuchi on 2022/03/26.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  let url: String

  func makeUIView(context: Context) -> WKWebView {
    WKWebView()
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    uiView.load(URLRequest(url: URL(string: url)!))
  }
}
