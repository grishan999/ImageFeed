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
    //новое имя нотификации
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange") // добавление нотификации
    
    static let shared = ProfileImageService()
    private(set) var avatarURL: String? = nil
    private var currentTask: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        
        // получаем токен с хранилища
        guard let token = OAuth2TokenStorage().token else {
            let errorMessage = "[fetchProfileImageURL]: MissingTokenError - token dismiss"
            print(errorMessage)
            completion(.failure(NetworkError.missingToken))
            return
        }
        
        // создание урл
        guard let urlComponents = URLComponents(string: "https://api.unsplash.com/users/\(username)") else {
            let errorMessage = "[fetchProfileImageURL]: MissingTokenError - can't create URLComponents"
            print(errorMessage)
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        guard let url = urlComponents.url else {
            let errorMessage = "[fetchProfileImageURL]: NetworkError url - can't create URL"
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
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            self?.currentTask = nil
            
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                self?.avatarURL = avatarURL
                
                DispatchQueue.main.async {
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                }
                
            case .failure(let error):
                let errorMessage = "[fetchProfileImageURL]: NetworkError - \(error.localizedDescription)"
                print (errorMessage)
                completion(.failure(error))
            }
        }
        
        self.currentTask = task // сохраняем ссылку на текущий запрос
        task.resume() // запускаем задачу
    }
}
