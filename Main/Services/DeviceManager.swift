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
        do{
            if let device = try DiStorage.loadDevice(){
                logger.i("Device loaded from storage", tag: LOG_TAG)
                return device;
            }
        }catch {
            logger.e("Error loading device from storage: \(error.localizedDescription)", tag: LOG_TAG)
        }
        logger.i("Device is empty, creating new", tag: LOG_TAG)
        
        let device = CreateDevice()
        
        return device
    }
    
    public static func UpdateDevice(_ device: Device){
        do{
            try DiStorage.saveDevice(device)
        } catch {
            logger.e("Error update device to storage: \(error.localizedDescription)", tag: LOG_TAG)
        }
        
        let deviceApi = DeviceApi()
        deviceApi.updateDevice(){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.logger.i("Update device success", tag: self.LOG_TAG)
                    break
                case .failure(let error):
                    self.logger.w("Update device failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                    break
                }
            }
        }
    }
    
    private static func CreateDevice() -> Device?{
        guard let id = UIDevice.current.identifierForVendor?.uuidString else {
            logger.e("Failed to get identifierForVendor", tag: LOG_TAG)
            return nil
        }
        
        guard let user = DiStorage.loadUser() else {
            logger.e("Fail to create device, user is empty", tag: LOG_TAG)
            return nil
        }
        let device = try? Device(hashSerialNumber: try HashGenerator.generateHash(salt: user.salt, input: id), typeDevice: .iOS,
                                 aPNsToken: DiStorage.loadApnsToken())
        logger.i("Device created", tag: LOG_TAG)
        
        do{
            try DiStorage.saveDevice(device!)
        } catch {
            logger.e("Error save device to storage: \(error.localizedDescription)", tag: LOG_TAG)
        }
        logger.i("Device saved to storage", tag: LOG_TAG)
        return device
    }
}
