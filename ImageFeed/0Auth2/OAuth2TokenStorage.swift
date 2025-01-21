//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 21.01.2025.
//

import UIKit

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"
    private let userDefaults = UserDefaults.standard

    var token: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}
