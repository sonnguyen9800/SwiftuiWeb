//
//  RichTextEditor.swift
//  SwiftuiWeb
//
//  Created by Son, Nguyen Hoang on 1/8/21.
//

import Foundation
import UIKit
import WebKit

public protocol RichTextEditorDelegate: class {
    func textDidChange(text: String)
    func heightDidChange()
}

fileprivate class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

class BodyContent: ObservableObject {
    @Published var data = "myData"
    init(content: String) {
        self.data = content
    }
}
public class RichTextEditor: UIView, WKScriptMessageHandler, WKNavigationDelegate, UIScrollViewDelegate {

    
    private static let textDidChange = "textDidChange" // Text link to js file's function
    private static let heightDidChange = "heightDidChange" // Text link to js file's method
    private static let defaultHeight: CGFloat = 60

    public weak var delegate: RichTextEditorDelegate?

    private var bodyContentModel = BodyContent(content: "")
    public var bodyContent : String
    public var height: CGFloat = RichTextEditor.defaultHeight

    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    private var textToLoad: String?
    
    public var text: String? {
        didSet {
            guard let text = text else { return }
            if editorView.isLoading {
                textToLoad = text
            } else {
                editorView.evaluateJavaScript("richeditor.insertText(\"\(text.htmlEscapeQuotes)\");", completionHandler: nil)
                placeholderLabel.isHidden = !text.htmlToPlainText.isEmpty
            }
        }
    }

    private var editorView: WKWebView!
    private let placeholderLabel = UILabel()

    public override init(frame: CGRect = .zero) {
        placeholderLabel.textColor = UIColor.lightGray.withAlphaComponent(0.65)

        let scriptPath = Bundle.main.path(forResource: "edit", ofType: "js")
        let scriptContent = try? String(contentsOfFile: scriptPath!, encoding: String.Encoding.utf8)
        let htmlPath = Bundle.main.path(forResource: "index", ofType: "html")
        let html = try? String(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8)
        
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(
            WKUserScript(source: scriptContent!,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )
        
        bodyContent = ""
        editorView = WKWebView(frame: .zero, configuration: configuration)
        editorView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        super.init(frame: frame)

        [RichTextEditor.textDidChange, RichTextEditor.heightDidChange].forEach {
            configuration.userContentController.add(WeakScriptMessageHandler(delegate: self), name: $0)
        }

        editorView.navigationDelegate = self
        editorView.isOpaque = false
        editorView.backgroundColor = .clear
        editorView.scrollView.isScrollEnabled = false
        editorView.scrollView.showsHorizontalScrollIndicator = false
        editorView.scrollView.showsVerticalScrollIndicator = false
        editorView.scrollView.bounces = false
        editorView.scrollView.isScrollEnabled = false
        editorView.scrollView.delegate = self

        addSubview(placeholderLabel)


        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addSubview(editorView)
        

        editorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            editorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            editorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            editorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        editorView.loadHTMLString(html!, baseURL: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.bodyContent = ""
        super.init(coder: aDecoder)
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case RichTextEditor.textDidChange:
            guard let body = message.body as? String else { return }
            placeholderLabel.isHidden = !body.htmlToPlainText.isEmpty
            delegate?.textDidChange(text: body)
            self.bodyContent = body
        case RichTextEditor.heightDidChange:
            guard let height = message.body as? CGFloat else { return }
            self.height = height > RichTextEditor.defaultHeight ? height + 30 : RichTextEditor.defaultHeight
            delegate?.heightDidChange()
        default:
            break
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let textToLoad = textToLoad {
            self.textToLoad = nil
            text = textToLoad
        }
    }

    public func viewForZooming(in: UIScrollView) -> UIView? {
        return nil
    }

}

fileprivate extension String {

    var htmlToPlainText: String {
        return [
            ("(<[^>]*>)|(&\\w+;)", " "),
            ("[ ]+", " ")
        ].reduce(self) {
            try! $0.replacing(pattern: $1.0, with: $1.1)
        }.resolvedHTMLEntities
    }

    var resolvedHTMLEntities: String {
        return self
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }

    func replacing(pattern: String, with template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: template)
    }

    var htmlEscapeQuotes: String {
        return [
            ("\"", "\\\""),
            ("“", "&quot;"),
            ("\r", "\\r"),
            ("\n", "\\n")
        ].reduce(self) {
            return $0.replacingOccurrences(of: $1.0, with: $1.1)
        }
    }
}
