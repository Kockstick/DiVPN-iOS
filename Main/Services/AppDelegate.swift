//
//  AppDelegate.swift
//  Outline
//
//  Created by Diesperov Konstantin on 02.10.2025.
//

import SwiftUI
import UIKit
import UserNotifications
import Foundation

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let LOG_TAG = "AppDelegate"
    let logger = DiLogger.shared
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool{
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            self.logger.i("didFinishLaunchingWithOptions: \(granted), \(error?.localizedDescription ?? "nil")", tag: self.LOG_TAG)
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        
        if var device = DeviceManager.GetDevice(){
            if token == device.aPNsToken{
                logger.i("APNs token is actual", tag: LOG_TAG)
                return
            }
            
            device.aPNsToken = token
            DeviceManager.UpdateDevice(device)
        }
        
        DiStorage.saveApnsToken(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.w("APNs register failed: \(error)")
    }
    
    //Тихие пуши
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                    fetchCompletionHandler completionHalder: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Пример: тянем статус подписки
        /*
        if let invId = userInfo["invId"] as? String {
            Api.shared.fetchPaymentStatus(invId: invId) { _ in
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
        }
         */
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        // 1) Сразу решаем про отображение, не задерживаем UI
        completionHandler([.banner, .list, .sound])

        // 2) Фильтрация по типу/категории, чтобы не долбить сеть на каждую чих-норификацию
        let userInfo = notification.request.content.userInfo
        _ = userInfo["type"] as? String
        _ = notification.request.content.categoryIdentifier
        
        TariffManager.shared.loadTariff() {_ in}
    }

}
