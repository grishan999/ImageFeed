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
    private var lastCode: String?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        
        lastCode = code
        
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
            guard let self = self else { return }
            self.currentTask = nil
            
            // если код запроса не совпадает с последним, значит, этот ответ устарел
            if lastCode != code {
                print("Received response for outdated code: \(code). Ignoring result.")
                // cообщаем об отмене устаревшего запроса
                completion(.failure(URLError(.cancelled)))
                return
            }
            
            switch result {
            case .success(let responseBody):
                let token = responseBody.accessToken
                self.tokenStorage.token = token
                completion(.success(token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        currentTask = task // сохраняем ссылку на текущий запрос
        task.resume() // запускаем задачу
        
    }
}
