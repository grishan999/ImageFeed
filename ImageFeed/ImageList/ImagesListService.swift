//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 20.02.2025.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // преобразование строки даты в объект Date
    private func date(from dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: dateString)
    }
    
    func fetchPhotos(completion: @escaping ([Photo]) -> Void) {
        guard currentTask == nil else {
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        // создание урл
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)") else {
            let errorMessage = "[fetchPhotosURL]: MissingError - can't create URLComponents"
            print(errorMessage)
            return
        }
        
        print("URL successfully created: \(url)")
        
        // создаем ревест (запрос)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // заголовок авторизации (токен)
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // создаем новый таск для запроса
        currentTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.currentTask = nil
            
            // Проверяем ошибки
            if let error = error {
                print("Error fetching photos: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            // жисон декодинг
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                
                // Преобразуем PhotoResult в Photo
                let newPhotos = photoResults.map { photoResult in
                    Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self.date(from: photoResult.createdAt),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser
                    )
                }
                
                // обновление массива фотос
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    // отправка нотификации
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        
        // запускаем задачу
        currentTask?.resume()
    }
}
