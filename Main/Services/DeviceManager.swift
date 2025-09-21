//
//  DeviceManager.swift
//  Outline
//
//  Created by Diesperov Konstantin on 21.09.2025.
//

import UIKit

class DeviceManager{
    
    private static let LOG_TAG: String = "DeviceManager"
    private static let logger = DiLogger.shared
    
    public static func GetHash() -> String{
        let device = GetDevice()
        let hash = device?.hashSerialNumber ?? "";
        return hash
    }
    
    public static func GetDevice() -> Device?{
        if let device = DiStorage.loadDevice(){
            logger.i("Device loaded from storage")
            return device;
        }
        logger.i("Device is empty, creating new")
        
        let device = CreateDevice()
        
        return device
    }
    
    private static func CreateDevice() -> Device?{
        guard let id = UIDevice.current.identifierForVendor?.uuidString else {
            logger.e("Failed to get identifierForVendor", tag: LOG_TAG)
            return nil
        }
        
        let user = DiStorage.loadUser()!
        let device = try? Device(hashSerialNumber: try HashGenerator.generateHash(salt: user.salt, input: id), typeDevice: .iOS)
        logger.i("Device created")
        
        DiStorage.saveDevice(device!)
        logger.i("Device saved to storage")
        return device
    }
}
