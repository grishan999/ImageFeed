//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 06.03.2025.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func handleAuthorizationCode(from url: URL) -> String?
    func makeOAuthTokenRequest(code: String) -> URLRequest?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        
        guard let request = authHelper.createAuthURLRequest(),
              var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            return
        }
        
        func code(from url: URL) -> String? {
            authHelper.getCode(from: url)
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func handleAuthorizationCode(from url: URL) -> String? {
        guard let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems,
              let codeItem = items.first(where: { $0.name == "code" }) else {
            return nil
        }
        return codeItem.value
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
}
