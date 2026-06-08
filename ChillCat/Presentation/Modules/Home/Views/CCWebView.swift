//
//  CCWebView.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import SwiftUI
import WebKit

struct CCWebView: View {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        CCWebViewRepresentable(url: url)
            .navigationTitle("浏览器")
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CCWebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
