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
    
    private let tokenStorage = OAuth2TokenStorage()
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = responseBody.accessToken
                    
                    self?.tokenStorage.token = token
                    
                    DispatchQueue.main.async {
                        completion(.success(token))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
