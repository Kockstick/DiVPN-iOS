//
//  DiStorage.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.08.2025.
//

import Foundation

internal class DiStorage{
    private static let USER_KEY = "save_user_key"
    private static let TARIFF_KEY = "save_tariff_key"
    private static let TOKEN_KEY = "jwt_token_key"
    private static let SS_KEY = "shadowsocks_key"
    private static let REFERRAL_CODE_KEY = "ref_code_key"
    private static let SERVER_KEY = "server_model_key"
    private static let DEVICE_KEY = "device_key"
    
    private static let LOG_TAG: String = "DiStorage"
    private static let logger = DiLogger.shared
    
    internal static func clearAll(){
        clearServer()
        clearToken()
        clearTariff()
        clearRefCode()
    }
    
    internal static func saveUser(user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: USER_KEY)
            logger.i("User saved to storage", tag: LOG_TAG)
        } else {
            logger.e("Failed to encode User", tag: LOG_TAG)
        }
    }
    
    internal static func loadUser() -> User? {
        if let data = UserDefaults.standard.data(forKey: USER_KEY),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            logger.i("User loaded from storage", tag: LOG_TAG)
            return user
        }
        logger.w("User not found in storage", tag: LOG_TAG)
        return nil
    }
    
    internal static func clearUser() {
        UserDefaults.standard.removeObject(forKey: USER_KEY)
        logger.i("User cleared from storage", tag: LOG_TAG)
    }
    
    internal static func saveTariff(tariff: CurrentTariffModel) {
        if let data = try? JSONEncoder().encode(tariff) {
            UserDefaults.standard.set(data, forKey: TARIFF_KEY)
            logger.i("Tariff saved to storage", tag: LOG_TAG)
        } else {
            logger.e("Failed to encode Tariff", tag: LOG_TAG)
        }
    }
    
    internal static func loadTariff() -> CurrentTariffModel? {
        if let data = UserDefaults.standard.data(forKey: TARIFF_KEY),
           let tariff = try? JSONDecoder().decode(CurrentTariffModel.self, from: data) {
            logger.i("Tariff loaded from storage", tag: LOG_TAG)
            return tariff
        }
        logger.w("Tariff not found in storage", tag: LOG_TAG)
        return nil
    }
    
    internal static func clearTariff() {
        UserDefaults.standard.removeObject(forKey: TARIFF_KEY)
        logger.i("Tariff cleared from storage", tag: LOG_TAG)
    }
    
    internal static func saveRefCode(code: String?) {
        guard let code, !code.isEmpty else { return }
        UserDefaults.standard.set(code, forKey: REFERRAL_CODE_KEY)
    }
    
    internal static func loadRefCode() -> String? {
        if let code = UserDefaults.standard.string(forKey: REFERRAL_CODE_KEY) {
            logger.i("Referral code loaded from storage", tag: LOG_TAG)
            return code
        }
        logger.w("Referral code not found in storage", tag: LOG_TAG)
        return nil
    }
    
    internal static func clearRefCode() {
        UserDefaults.standard.removeObject(forKey: REFERRAL_CODE_KEY)
        logger.i("Referral code cleared from storage", tag: LOG_TAG)
    }
    
    internal static func saveServer(_ server: ServerModel) {
        if let data = try? JSONEncoder().encode(server) {
            UserDefaults.standard.set(data, forKey: SERVER_KEY)
            logger.i("Server saved to storage", tag: LOG_TAG)
        } else {
            logger.e("Failed to encode ServerModel", tag: LOG_TAG)
        }
    }
    
    internal static func loadServer() -> ServerModel? {
        if let data = UserDefaults.standard.data(forKey: SERVER_KEY),
        let server = try? JSONDecoder().decode(ServerModel.self, from: data) {
         logger.i("Server loaded from storage", tag: LOG_TAG)
         return server
     }
     logger.w("Server not found in storage", tag: LOG_TAG)
     return nil
    }
    
    internal static func clearServer() {
        UserDefaults.standard.removeObject(forKey: SERVER_KEY)
        logger.i("Server model cleared from storage", tag: LOG_TAG)
    }
    
    internal static func saveDevice(_ device: Device) {
        if let data = try? JSONEncoder().encode(device) {
            UserDefaults.standard.set(data, forKey: DEVICE_KEY)
            logger.i("Device saved to storage", tag: LOG_TAG)
        } else {
            logger.e("Failed to encode Device", tag: LOG_TAG)
        }
    }
    
    internal static func loadDevice() -> Device? {
        if let data = UserDefaults.standard.data(forKey: DEVICE_KEY),
           let device = try? JSONDecoder().decode(Device.self, from: data) {
            logger.i("Device loaded from storage", tag: LOG_TAG)
            return device
        }
        logger.w("Device not found in storage", tag: LOG_TAG)
        return nil
    }
    
    internal static func clearDevice() {
        UserDefaults.standard.removeObject(forKey: DEVICE_KEY)
        logger.i("Device cleared from storage", tag: LOG_TAG)
    }
    
    internal static func saveToken(token: TokenResult) {
        if let data = try? JSONEncoder().encode(token) {
            UserDefaults.standard.set(data, forKey: TOKEN_KEY)
            logger.i("Token saved to storage", tag: LOG_TAG)
        } else {
            logger.e("Failed to encode Token", tag: LOG_TAG)
        }
    }

    internal static func loadToken() -> TokenResult? {
        if let data = UserDefaults.standard.data(forKey: TOKEN_KEY),
           let token = try? JSONDecoder().decode(TokenResult.self, from: data) {
            logger.i("Token loaded from storage", tag: LOG_TAG)
            return token
        }
        logger.w("Token not found in storage", tag: LOG_TAG)
        return nil
    }

    internal static func clearToken() {
        UserDefaults.standard.removeObject(forKey: TOKEN_KEY)
        logger.i("Token cleared from storage", tag: LOG_TAG)
    }

}
