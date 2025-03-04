//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 20.02.2025.
//

import Foundation

final class ImagesListService {
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private var dataTask: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private lazy var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    func fetchPhotos(completion: @escaping ([Photo]) -> Void) {
        guard currentTask == nil else {
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        if nextPage == 1 {
            photos.removeAll()
        }
        
        // создание урл
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)") else {
            let errorMessage = "[fetchPhotosURL]: MissingError - can't create URL"
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
                        isLiked: photoResult.isLiked
                    )
                }
                
                // обновление массива фотос
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    print("Loaded \(newPhotos.count) new photos. Total photos: \(self.photos.count)")
                    
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
    
    // преобразование строки даты в объект Date
    private func date(from dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        return iso8601Formatter.date(from: dateString)
    }
    
    // функциональность лайков
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        // проверка корректности photoId
        guard !photoId.isEmpty else {
            print("Error: photoId is empty")
            return
        }
        
        // Формирование URL
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            print("Error: Invalid URL for photo ID: \(photoId)")
            return
        }
        print("URL successfully created: \(url)")
        
        // чекаем текущую задачу
        guard currentTask == nil else {
            print("A task is already in progress.")
            return
        }
        
        // настройка запроса
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        // добавление токена авторизации
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error: Authorization token is missing")
            return
        }
        
        //обнуление предыдущей задачи
        if let existingTask = dataTask {
            existingTask.cancel()
        }
        
        // создание новой задачи
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.currentTask = nil
            
            // обработка ошибок
            if let error = error {
                print("Error changing like: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // обработка ответа сервера
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("Like status updated successfully")
                    completion(.success(()))
                } else {
                    let statusCodeError = NSError(domain: "ImageFeed", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned unexpected status code"])
                    print("Unexpected status code: \(httpResponse.statusCode)")
                    completion(.failure(statusCodeError))
                }
            } else {
                let unknownError = NSError(domain: "ImageFeed", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                print("Unknown error occurred while changing like")
                completion(.failure(unknownError))
            }
        }
        // запуск задачи
        dataTask.resume()
        self.dataTask = dataTask
    }
    
    func cleanImagesList() {
        photos = []
        lastLoadedPage = nil
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> Array {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
