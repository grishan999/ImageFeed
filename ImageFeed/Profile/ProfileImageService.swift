//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 04.02.2025.
//

import UIKit

struct UserResult: Codable {
    struct ProfileImages: Codable {
        let small: String
    }
    
    let profileImage: ProfileImages
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}


final class ProfileImageService {
    
    private init() {}
    
    static let shared = ProfileImageService()
    private(set) var avatarURL: String? = nil
    private var currentTask: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        
        
        // получаем токен с хранилища
        guard let token = OAuth2TokenStorage().token else {
            let errorMessage = "Error: Failed to retrieve token from storage."
            print(errorMessage)
            completion(.failure(NetworkError.missingToken)) // Изменил тип ошибки
            return
        }
        
        // создание урл
        guard let urlComponents = URLComponents(string: "https://api.unsplash.com/users/\(username)") else {
            let errorMessage = "Error: Failed to create URLComponents."
            print(errorMessage)
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        guard let url = urlComponents.url else {
            let errorMessage = "Error: Failed to create URL."
            print(errorMessage)
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        print("URL successfully created: \(url)")
        
        // создание реквест
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
        
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
                let userResult = try decoder.decode(UserResult.self, from: data)
                
                // Сохраняем урл аватарки
                self.avatarURL = userResult.profileImage.small
                
                DispatchQueue.main.async {
                    completion(.success(userResult.profileImage.small))
                    print("Avatar URL fetched successfully: \(userResult.profileImage.small)")
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("Completion called with decoding error.")
                }
            }
        }
        
        self.currentTask = task // Сохраняем ссылку на текущий запрос
        task.resume() // Запускаем задачу
    }
}
