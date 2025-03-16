//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 27.02.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        cleanCookies()
        cleanProfilePhoto()
        cleanProfileData()
        cleanImagesList()
        navigateToAuthView()
    }

    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes, for: [record],
                    completionHandler: {})
            }
        }
    }

    private func cleanProfilePhoto() {
        ProfileImageService.shared.cleanProfilePhoto()
    }

    private func cleanProfileData() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.cleanProfileData()
    }

    private func cleanImagesList() {
        ImagesListService.shared.cleanImagesList()
    }

    private func navigateToAuthView() {
        DispatchQueue.main.async {

            guard
                let scene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene,
                let sceneDelegate = scene.delegate as? SceneDelegate,
                let window = sceneDelegate.window
            else { return }

            // загрузка ауфКонтроллера из SB
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard
                let authViewController = storyboard.instantiateViewController(
                    withIdentifier: "AuthViewController") as? AuthViewController
            else { return }

            let navigationController = UINavigationController(
                rootViewController: authViewController)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}
