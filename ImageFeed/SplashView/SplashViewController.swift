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
    
    private var isAuthorized: Bool {
        return storage.token != nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAuthorized {
            print("User is already authorized.")
            
            // Если токен есть
            guard let token = storage.token else {
                print("Error: Token is missing.")
                return
            }
            
            fetchProfile(token: token) // Добавляем вызов
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    
    private func switchToTabBarController() {
        
        guard let window = UIApplication.shared.windows.first else {
            print ("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                print ("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
                self.performSegue(withIdentifier: self.showAuthenticationScreenSegueIdentifier, sender: nil)
            }
        }
    }
}
