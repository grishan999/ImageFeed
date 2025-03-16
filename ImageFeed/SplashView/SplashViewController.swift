//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 21.01.2025.
//
import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var isAuthorized: Bool {
        return storage.token != nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isAuthorized {
            print("User is already authorized.")
            switchToTabBarController()
        } else {
            showAuthViewController()
        }

        view.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            print("Invalid window configuration")
            return
        }

        let tabBarController = UITabBarController()

        // ImagesListViewController
        guard
            let imagesListStoryboard = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(
                    withIdentifier: "ImagesListViewController")
                as? ImagesListViewController
        else {
            print(
                "Failed to instantiate ImagesListViewController from storyboard"
            )
            return
        }
        imagesListStoryboard.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )

        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        tabBarController.viewControllers = [
            imagesListStoryboard, profileViewController,
        ]
        tabBarController.tabBar.barTintColor = UIColor(named: "YP Black")
        tabBarController.tabBar.tintColor = UIColor.white

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController") as? AuthViewController
        else {
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
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.storage.token = token
                    print("Token successfully saved: \(token)")
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("Failed to fetch token: \(error)")
                }
            }
        }
    }
}
