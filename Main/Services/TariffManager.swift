//
//  TariffManager.swift
//  Outline
//
//  Created by Diesperov Konstantin on 20.08.2025.
//


import SwiftUI

class TariffManager: ObservableObject {
    static var shared = TariffManager()
    
    @Published private(set) var tariff: CurrentTariffModel?
    @Published private(set) var isFreeTrial: Bool = true
    
    private let LOG_TAG = "TariffManager"
    private let logger = DiLogger.shared
    
    var isActiveTariff: Bool {
        if daysToEntTariff == nil { return false }
        return daysToEntTariff! > 0
    }
    
    var daysToEntTariff: Int? {
        guard let tariff = tariff else { return nil }
        
        let now = Date()
        let end = Calendar.current.date(byAdding: .day, value: 1, to: tariff.dateEnd) ?? tariff.dateEnd
        
        return Calendar.current.dateComponents([.day], from: now, to: end).day
    }
    
    var daysToEntTariffText: String {
        guard let tariff = tariff else { return "..." }
        
        let daysLeft = daysToEntTariff ?? 0
        
        return "\(daysLeft)"
    }
    
    var tariffName: String {
        guard let tariff = tariff else { return "Subscription" }
        return tariff.name
    }
    
    var tariffLoading: Bool {
        return tariff == nil
    }
    
    func loadTariff(completion: @escaping (Result<CurrentTariffModel, Error>) -> Void){
        logger.i("loadTariff called", tag: LOG_TAG)
        
        if let tariff = DiStorage.loadTariff() {
            self.tariff = tariff
            isFreeTrial = tariff.name == "Trial"
            logger.i("Tariff loaded from storage", tag: LOG_TAG)
            self.notifyTariffEnd(self.daysToEntTariff)
            completion(.success(tariff))
            return
        }
        
        let userApi = UserApi()
        userApi.getTariff(){ result in
            DispatchQueue.main.async {
                switch result{
                case .success(let tariff):
                    self.tariff = tariff
                    self.isFreeTrial = tariff.name == "Trial"
                    DiStorage.saveTariff(tariff: tariff)
                    self.logger.i("Tariff loaded from API and saved", tag: self.LOG_TAG)
                    completion(.success(tariff))
                    break
                case .failure(let error):
                    self.logger.w("Tariff load failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                    completion(.failure(error))
                    break
                }
            }
        }
    }
    
    private func notifyTariffEnd(_ days: Int?){
        if days == nil{
            logger.w("Tariff end date not found", tag: LOG_TAG)
            return
        }
        
        if(tariff?.name == "Trial"){
             if days! <= 0 {
                 logger.i("Trial ended -> show continue notice", tag: LOG_TAG)
                DiNotification.shared.showRow(NSLocalizedString("continue_requires_subscription", comment: ""))
                return
            } else {
                logger.i("Trial active", tag: LOG_TAG)
            }
        }
        
        if days! <= 0 {
            logger.i("Tariff expired -> show renew notice", tag: LOG_TAG)
            DiNotification.shared.showRow(NSLocalizedString("renew_subscription_notice", comment: ""))
            return
        } else {
            logger.i("Tariff active", tag: LOG_TAG)
        }
    }
}
