//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 16.01.2025.
//

import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
             })
        
        
        
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        
        
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    } 
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Error: Unable to create base URL")
            return nil
        }
        print(" Base URL successfully created: \(baseURL)")
        
        let tokenPath = "/oauth/token"
        guard var urlComponents = URLComponents(string: baseURL.absoluteString + tokenPath) else {
            print("Error: Unable to create URL components")
            return nil
        }
        print("URLComponents successfully created: \(urlComponents)")
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        print("Query items successfully added: \(urlComponents.queryItems ?? [])")
        
        guard let url = urlComponents.url else {
            print("Error: Unable to create URL")
            return nil
        }
        print(" Final URL successfully created: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("URLRequest successfully created: \(request)")
        
        return request
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
                presenter?.didUpdateProgressValue(webView.estimatedProgress)
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
          _ webView: WKWebView,
          decidePolicyFor navigationAction: WKNavigationAction,
          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
      ) {
          if let url = navigationAction.request.url,
             let code = presenter?.handleAuthorizationCode(from: url) {
              delegate?.webViewViewController(self, didAuthenticateWithCode: code)
              decisionHandler(.cancel)
          } else {
              decisionHandler(.allow)
          }
      }
    
   
}
