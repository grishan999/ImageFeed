//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 21.01.2025.
//

import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"
    private let userDefaults = UserDefaults.standard
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            }
            else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
