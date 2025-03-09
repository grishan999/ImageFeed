//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 09.03.2025.
//

import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapExitButton()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileService: ProfileService = .shared,
         profileImageService: ProfileImageService = .shared,
         logoutService: ProfileLogoutService = .shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        setupObservers()
        fetchProfile()
    }
    
    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    
    private func fetchProfile() {
        guard let token = OAuth2TokenStorage().token else {
            print("Ошибка: нет токена")
            return
        }
        
        print("Токен успешно получен: \(token)")
        
        profileService.fetchProfile(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("Профиль успешно загружен: \(profile)")
                    self?.view?.updateUI(with: profile)
                    self?.fetchProfileImageURL(username: profile.username)
                case .failure(let error):
                    print("Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchProfileImageURL(username: String) {
        print("Загрузка URL аватара для пользователя: \(username)")
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let urlString):
                    print("URL аватара успешно загружен: \(urlString)")
                    if let url = URL(string: urlString) {
                        self?.updateAvatar(with: url)
                    } else {
                        print("Ошибка: не удалось создать URL из строки \(urlString)")
                    }
                case .failure(let error):
                    print("Ошибка загрузки URL аватара: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateAvatar(with url: URL) {
        view?.updateAvatar(with: url)
    }
    
    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        view?.updateAvatar(with: url)
    }
    
    func didTapExitButton() {
        showAlertForExit()
    }
    
    private func showAlertForExit() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesButton = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.performLogout()
        }
        
        let noButton = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        
        view?.presentAlert(alert)
    }
    
    private func performLogout() {
        logoutService.logout()
        print("Профиль обнулен")
    }
}
