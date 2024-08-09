import SwiftUI
import WebKit

struct BaskanView: View {
    var body: some View {
        WebViewBaskan(urlString: "https://giresun.bel.tr/baskan-yardimcilari/", injectJavaScript: true)
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebViewBaskan: UIViewRepresentable {
    let urlString: String
    let injectJavaScript: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()

        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        if injectJavaScript {
            let script = """
                var header = document.querySelector('div#header');
                if (header) {
                    header.style.display = 'none';
                }
            """
            let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            let userContentController = WKUserContentController()
            userContentController.addUserScript(userScript)

            let config = WKWebViewConfiguration()
            config.userContentController = userContentController

            return WKWebView(frame: .zero, configuration: config)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct BaskanView_Previews: PreviewProvider {
    static var previews: some View {
        BaskanView()
    }
}
