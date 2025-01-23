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
    
    private var isAuthorized: Bool {
        return storage.token != nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if storage.token != nil {
            print("User is already authorized.")
            switchToTabBarController()
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
                        self?.switchToTabBarController()
                    case .failure(let error):
                        print("Failed to fetch token: \(error)")
                    }
                }
            }
        }
    }
}
