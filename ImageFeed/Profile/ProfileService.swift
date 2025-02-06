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
    static let shared = ProfileService()
    private(set) var profile: Profile? = nil
    
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
            let errorMessage = "[fetchProfile]: NetworkError - can't create URL."
            print(errorMessage)
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        print("URL successfully created: \(url)")
        
        // создание реквест
        guard let request = createAuthRequest(url: url, token: token) else {
            let errorMessage = "[fetchProfile]: NetworkError  - can't create URLRequest."
            print(errorMessage)
            completion(.failure(NetworkError.requestCancelled))
            return
        }
        
        // создаем новый таск для запроса
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            
            // Очищаем ссылку на текущий запрос
            self?.currentTask = nil
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                let errorMessage = "[fetchProfile]: NetworkError - \(error.localizedDescription)"
                print (errorMessage)
                completion(.failure(error))
            }
        }
        
        currentTask = task // сохраняем ссылку на текущий запрос
        task.resume() // запускаем задачу
    }
}
