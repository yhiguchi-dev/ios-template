//
//  ContentView.swift
//  Template
//
//  Created by Yuki Higuchi on 2022/02/19.
//

import SwiftUI

public struct ContentView: View {
  public init() {
  }
  public var body: some View {
    //    Text("Hello, world!")
    //      .padding()
    WebView(url: "http://yuki.local:3000/")
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
