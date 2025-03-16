//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 07.03.2025.
//

import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var makeOAuthTokenRequestCalled = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func handleAuthorizationCode(from url: URL) -> String? {
        return nil
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        makeOAuthTokenRequestCalled = true
        return nil
    }
}

