//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 15.01.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                print ("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Received authorization code: \(code)")
        
        OAuth2Service.shared.fetchOAuthToken(code) { result in
            switch result {
            case .success(let token):
                print("Successfully retrieved token: \(token)")
                
                // Сохранение токена в UserDefaults
                let tokenStorage = OAuth2TokenStorage()
                tokenStorage.token = token
                print("Token saved successfully.")
                
                // Переход на следующий экран
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
                
            case .failure(let error):
                print("Failed to retrieve token: \(error)")
                
                // Отображение ошибки пользователю
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ошибка",
                                                  message: "Не удалось авторизоваться. Попробуйте ещё раз.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
