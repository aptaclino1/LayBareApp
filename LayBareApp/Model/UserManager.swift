//
//  UserManager.swift
//  LayBareApp
//
//  Created by Messiah on 1/21/24.
//

import Foundation
import UIKit
import Security

struct UserAccountManager {
    static let shared = UserAccountManager()
    
    private let emailKey = "email"
    private let fullNameKey = "fullName"
    private let userImageKey = "userImage"
    private let isLoggedInKey = "isLoggedIn"
    
    var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: isLoggedInKey)
    }
    
    func createAccount(email: String, password: String, fullName: String, userImage: UIImage?) throws {
        guard !userExists(email: email) else {
            print("Email already exists.")
            throw UserAccountManagerError.emailExists
        }
        guard isPasswordValid(password) else {
            print("Password does not meet requirements.")
            throw UserAccountManagerError.invalidPassword
        }
        UserDefaults.standard.set(email, forKey: emailKey)
        UserDefaults.standard.set(fullName, forKey: fullNameKey)
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        try KeychainService.savePassword(password, forAccount: email)
        setUserImage(userImage)
        print("Account created successfully.")
    }
    
    func setUserImage(_ image: UIImage?) {
        if let imageData = image?.pngData() {
            UserDefaults.standard.set(imageData, forKey: userImageKey)
        }
    }
    
    func getUserImage() -> UIImage? {
        if let imageData = UserDefaults.standard.data(forKey: userImageKey) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func getFullName() -> String? {
        return UserDefaults.standard.string(forKey: fullNameKey)
    }
    
    func getEmail() -> String? {
        return UserDefaults.standard.string(forKey: emailKey)
    }
    
    private func userExists(email: String) -> Bool {
        return UserDefaults.standard.string(forKey: emailKey) == email
    }
    
    func login(email: String, password: String) throws -> Bool {
        if !userExists(email: email) {
            throw UserAccountManagerError.invalidCredentials
        }
        do {
            let savedPassword = try KeychainService.loadPassword(forAccount: email)
            
            print("Entered password: \(password)")
            print("Saved password: \(savedPassword)")
            
            if savedPassword == password {
                UserDefaults.standard.set(true, forKey: isLoggedInKey)
                print("Login successful.")
                return true
            } else {
                print("Invalid credentials.")
                throw UserAccountManagerError.invalidCredentials
            }
        } catch {
            print("Error retrieving saved password: \(error)")
            throw UserAccountManagerError.invalidCredentials
        }
    }
    
    func logout() {
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
        print("Logged out successfully.")
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{}|;:'\",.<>?/")
        let uppercaseCharacterSet = CharacterSet.uppercaseLetters
        let lowercaseCharacterSet = CharacterSet.lowercaseLetters
        let digitCharacterSet = CharacterSet.decimalDigits
        guard !password.containsConsecutiveIdenticalCharacters() else {
            return false
        }
        return password.rangeOfCharacter(from: specialCharacterSet) != nil &&
        password.rangeOfCharacter(from: uppercaseCharacterSet) != nil &&
        password.rangeOfCharacter(from: lowercaseCharacterSet) != nil &&
        password.rangeOfCharacter(from: digitCharacterSet) != nil &&
        password.count >= 8
    }
}

enum UserAccountManagerError: Error {
    case emailExists
    case invalidPassword
    case invalidCredentials

    var localizedDescription: String {
        switch self {
        case .emailExists:
            return "Email already exists. Please use another email address."
        case .invalidPassword:
            return "Password must contain at least one special character, one uppercase letter, and one lowercase letter."
        case .invalidCredentials:
            return "Invalid credentials. Please check your email and password."
        }
    }
}

struct KeychainService {
    static let serviceIdentifier = Bundle.main.bundleIdentifier ?? "com.GeloCide.SampleApp1"

    static func savePassword(_ password: String, forAccount account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: account,
            kSecValueData as String: password.data(using: .utf8)!
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            throw KeychainError.saveError(status)
        }
    }

    static func loadPassword(forAccount account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]

        var dataTypeRef: AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data, let password = String(data: data, encoding: .utf8) {
            return password
        } else {
            throw KeychainError.loadError(status)
        }
    }
}

enum KeychainError: Error {
    case saveError(OSStatus)
    case loadError(OSStatus)

    var localizedDescription: String {
        switch self {
        case .saveError(let status):
            return "Keychain save error: \(status)"
        case .loadError(let status):
            return "Keychain load error: \(status)"
        }
    }
}

    extension String {
        func containsConsecutiveIdenticalCharacters() -> Bool {
            for i in 1..<count {
                if self[index(startIndex, offsetBy: i)] == self[index(startIndex, offsetBy: i - 1)] {
                    return true
                }
            }
            return false
        }
    }
