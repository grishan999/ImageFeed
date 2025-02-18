//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 21.01.2025.
//
import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService()
    
    let ypBlackColor = UIColor(named: "YP Black")
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView ()
        imageView.image = UIImage(named: "Vector")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var isAuthorized: Bool {
        return storage.token != nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // проверка авторизации
        if isAuthorized {
            print("User is already authorized.")
            
            // Если токен есть
            guard let token = storage.token else {
                print("Error: Token is missing.")
                return
            }
            
            fetchProfile(token: token) // Добавляем вызов
        } else {
            // если токена нет, переходим на экран авторизации
            showAuthViewController()
        }
        
        //цвет
        view.backgroundColor = UIColor(named: "YP Black")
        
        //добавляем лого на экран
        view.addSubview(logoImageView)
        
        // активирую констрейнты
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    private func switchToTabBarController() {
        
        guard let window = UIApplication.shared.windows.first else {
            print ("Invalid window configuration")
            return
        }
        
        // получение imagesListStoryboard из сториборда
        guard let imagesListStoryboard = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            print("Failed to instantiate ImagesListViewController from storyboard")
            return
        }
        
        // настройка таб бар элемента для imagesListStoryboard
        imagesListStoryboard.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named:"tab_editorial_active"),
            selectedImage: nil
        )
        
        // настройка таб бар элемента для profileViewController
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        // создаем TabBarController и добавляем дочерние контроллеры
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            imagesListStoryboard,
            profileViewController
        ]
        
        tabBarController.tabBar.barTintColor = UIColor(named: "YP Black") // Фон таб бара
        tabBarController.tabBar.tintColor = UIColor.white // Цвет активной иконки
        
        // устанавливаем TabBarController как корневой контроллер
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, withCode code: String) {
        vc.dismiss(animated: true) {
            OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let token):
                        self?.storage.token = token
                        print("Token successfully saved: \(token)")
                        
                        if let token = self?.storage.token {
                            self?.fetchProfile(token: token)
                        }
                        
                    case .failure(let error):
                        print("Failed to fetch token: \(error)")
                    }
                }
            }
        }
    }
}

extension SplashViewController {
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("Profile fetched successfully.")
                
                // получаем username из профиля
                let username = profile.username
                
                // запуск запроса аватарки
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in
                    print("Avatar URL request started for user: \(username)")
                }
                
                self.switchToTabBarController()
                
            case .failure(let fetchError):
                print("Failed to fetch profile: \(fetchError)")
                
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Не удалось получить данные профиля. Попробуйте войти снова.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
                self.storage.token = nil
                self.showAuthViewController()
            }
        }
    }
}
