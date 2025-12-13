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
    
    private let PRICE_KEY = "subscribtionPriceKey"
    @Published private(set) var subscribtionPrice: Int? {
        didSet {
            savePrice()
        }
    }
    
    private let STATUS_KEY = "subscribtion_status_key"
    @Published private(set) var subscribtionStatus: StatusSubscribtion? {
        didSet{
            saveStatus()
        }
    }
    
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
    
    var subscribtionPriceText: String {
        guard let subscribtionPrice = subscribtionPrice else { return "...₽" }
        return "\(subscribtionPrice)₽"
    }
    
    var tariffName: String {
        guard let tariff = tariff else { return "Subscription" }
        return tariff.name
    }
    
    var tariffLoading: Bool {
        return tariff == nil
    }
    
    func loadTariff(completion: @escaping (Result<CurrentTariffModel, Error>) -> Void){
        loadPrice()
        loadStatus()
        loadSubscribtionPrice()
        logger.i("loadTariff called", tag: LOG_TAG)
        
        if let tariff = DiStorage.loadTariff() {
            self.tariff = tariff
            isFreeTrial = tariff.name == "Trial"
            logger.i("Tariff loaded from storage", tag: LOG_TAG)
        }
        
        let invoiceApi = InvoiceApi()
        invoiceApi.getSubscribtionStatus() {res in
            DispatchQueue.main.async {
                switch res{
                case .success(let statusModel):
                    self.subscribtionStatus = statusModel
                    self.isFreeTrial = self.subscribtionStatus == .trial
                    self.logger.i("Subscribtion status: \(self.subscribtionStatus)")
                    break
                case .failure(let error):
                    self.logger.w("Get subscribtion status failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                    break
                }
            }
        }
        
        let userApi = UserApi()
        userApi.getTariff(){ result in
            DispatchQueue.main.async {
                switch result{
                case .success(let tariff):
                    self.tariff = tariff
                    DiStorage.saveTariff(tariff: tariff)
                    self.notifyTariffEnd(self.daysToEntTariff)
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
    
    func updateTariff(){
        DiStorage.clearTariff()
        loadTariff { _ in }
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
                DiNotification.shared.hideRow(NSLocalizedString("continue_requires_subscription", comment: ""))
                logger.i("Trial active", tag: LOG_TAG)
                return
            }
        }
        
        if days! <= 0 {
            logger.i("Tariff expired -> show renew notice", tag: LOG_TAG)
            DiNotification.shared.showRow(NSLocalizedString("renew_subscription_notice", comment: ""))
            return
        } else {
            logger.i("Tariff active", tag: LOG_TAG)
            DiNotification.shared.hideRow(NSLocalizedString("renew_subscription_notice", comment: ""))
        }
    }
    
    private func loadSubscribtionPrice(){
        let invoiceApi = InvoiceApi()
        invoiceApi.getSubscribtionPrice { result in
            switch result{
            case .success(let priceModel):
                DispatchQueue.main.async {
                    self.subscribtionPrice = priceModel.price
                    self.logger.i("Subscribtion price: \(self.subscribtionPrice)", tag: self.LOG_TAG)
                }
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    self.logger.e("Subscribtion price load failed: \(error.localizedDescription)", tag: self.LOG_TAG)
                }
                break
            }
        }
    }
    
    private func savePrice() {
        if let price = subscribtionPrice {
            UserDefaults.standard.set(price, forKey: PRICE_KEY)
        } else {
            UserDefaults.standard.removeObject(forKey: PRICE_KEY)
        }
    }
    
    private func loadPrice() {
        if UserDefaults.standard.object(forKey: PRICE_KEY) != nil {
            self.subscribtionPrice = UserDefaults.standard.integer(forKey: PRICE_KEY)
        } else {
            self.subscribtionPrice = nil
        }
    }
    
    private func saveStatus() {
        if let status = subscribtionStatus {
            UserDefaults.standard.set(status.rawValue, forKey: STATUS_KEY)
        } else {
            UserDefaults.standard.removeObject(forKey: STATUS_KEY)
        }
    }

    private func loadStatus() {
        if let rawValue = UserDefaults.standard.object(forKey: STATUS_KEY) as? Int,
           let status = StatusSubscribtion(rawValue: rawValue) {
            self.subscribtionStatus = status
        } else {
            self.subscribtionStatus = nil
        }
    }
}
