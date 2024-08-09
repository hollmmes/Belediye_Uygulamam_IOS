import SwiftUI
import WebKit

struct CustomWebView: UIViewRepresentable {
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
        var parent: CustomWebView
        var injectJavaScript: Bool

        init(_ parent: CustomWebView, injectJavaScript: Bool) {
            self.parent = parent
            self.injectJavaScript = injectJavaScript
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if injectJavaScript {
                let jsCode = """
                javascript:(function() {
                    var element = document.querySelector(".TumSli");
                    if (element) {
                        document.body.innerHTML = "";
                        document.body.appendChild(element);
                        document.body.style.overflow = 'hidden';
                    } else {
                        console.log('Element bulunamadı');
                    }

                    // .owl-dots sınıfını kaldır
                    var dots = document.querySelectorAll(".owl-dots");
                    dots.forEach(function(dot) {
                        dot.style.display = 'none';
                    });
                })();
                """
                webView.evaluateJavaScript(jsCode, completionHandler: nil)
            }
        }

        // Link tıklamalarını tarayıcıda açmak için
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
