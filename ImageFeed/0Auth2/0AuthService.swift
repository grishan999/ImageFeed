//
//  0AuthService.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 21.01.2025.
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}


final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage()
    private var currentTask: URLSessionTask?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            let errorMessage = "[fetchOAuthToken]: NetworkError - can't create URL"
            print(errorMessage)
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        print("URL successfully created: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("HTTP request configured with method POST and Content-Type application/json")
        
        let parameters: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            let errorMessage = "[fetchOAuthToken]: - \(error.localizedDescription)"
            print(errorMessage)
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            
            self?.currentTask = nil
            switch result {
            case .success(let responseBody):
                let token = responseBody.accessToken
                self?.tokenStorage.token = token
                completion(.success(token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        currentTask = task // сохраняем ссылку на текущий запрос
        task.resume() // запускаем задачу
    }
}

