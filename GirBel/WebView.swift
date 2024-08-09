import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String
    let injectJavaScript: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, injectJavaScript: injectJavaScript)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var injectJavaScript: Bool

        init(_ parent: WebView, injectJavaScript: Bool) {
            self.parent = parent
            self.injectJavaScript = injectJavaScript
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if injectJavaScript {
                let jsCode = """
                document.getElementById('header').style.display='none';
                document.getElementById('footer').style.display='none';
                document.body.style.transform='translateY(-70px)';
                """
                webView.evaluateJavaScript(jsCode, completionHandler: nil)
            }
        }
    }
}
