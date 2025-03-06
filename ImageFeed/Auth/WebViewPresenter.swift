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
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        
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

}
