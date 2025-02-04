//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 03.02.2025.
//

import UIKit

struct ProfileResult: Codable {
    let username: String
    let name: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init (profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = [profileResult.firstName, profileResult.lastName] .compactMap { $0 }.joined(separator: " ")
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}

final class ProfileService {
    
    private var currentTask: URLSessionTask?
    
    //создаем auth request
    func createAuthRequest (url: URL, token: String) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        currentTask?.cancel()
        
        // создание урл
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            let errorMessage = "Error: Failed to create URL from string 'https://api.unsplash.com/me'."
            print(errorMessage)
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        print("URL successfully created: \(url)")
        
        // создание реквест
        guard let request = createAuthRequest(url: url, token: token) else {
            let errorMessage = "Error: Failed to create URLRequest."
            print(errorMessage)
            completion(.failure(NetworkError.requestCancelled))
            return
        }
        
        // создаем новый таск для запроса
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Очищаем ссылку на текущий запрос
            self.currentTask = nil
            
            // Проверяем был ли запрос отменен
            if let error = error as? URLError, error.code == .cancelled {
                print("Request was cancelled.")
                return
            }
            
            // ошибка сети
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // проверка статуса ответа
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                print("Error: Invalid HTTP response.")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            // декодинг
            do {
                let decoder = JSONDecoder()
                let profileResult = try decoder.decode(ProfileResult.self, from: data)
                let profile = Profile(profileResult: profileResult)
                
                DispatchQueue.main.async {
                    completion(.success(profile))
                    print("Completion called with success")
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("Completion called with decoding error.")
                }
            }
        }
        
        // Сохраняем ссылку на текущий запрос
        self.currentTask = task
        
        // Запускаем задачу
        task.resume()
    }
    
}





