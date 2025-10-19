//
//  ChangeCardView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 18.10.2025.
//

import SwiftUI

struct ChangeCardView: View{
    @Environment(\.dismiss) private var dismiss
    
    @State private var paymentUrl: URL?
    @State var openPaymentPage: Bool = false
    @State var showSafariView: Bool = false
    @State var isLoadingDate: Bool = false
    
    private let CHANGE_DATE_KEY = "change_payment_method_date"
    @State var changePaymentDate: Date? {
        didSet{
            saveChangeDate()
        }
    }
    var changePaymentDateText: String{
        guard let dt = changePaymentDate else {
            return "••.••.••••"
        }
        
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.locale = Locale(identifier: "ru_RU")
        fmt.timeZone = .current
        fmt.dateFormat = "dd.MM.yyyy"
        
        return fmt.string(from: dt)
    }
    
    private let LOG_TAG: String = "ReportView"
    private let logger = DiLogger.shared
    
    var body: some View{
        VStack{
            Spacer()
                .frame(maxHeight: 50)
            
            Image("paid")
                .font(.system(size: 180, weight: .light))
                .foregroundColor(Color("TextPrimary"))
            
            Spacer()
                .frame(maxHeight: 15)
            
            Text("Change Card")
                .font(.largeTitle).bold()
                .foregroundColor(Color("TextPrimary"))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
                .frame(maxHeight: 30)
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
                .frame(maxHeight: 30)
            
            Text("Date last change: \(changePaymentDateText)")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(6)
                .shimmer(changePaymentDate == nil || isLoadingDate)
            
            Spacer()
                .frame(maxHeight: 20)
            
            Text("A payment of 1₽ is required to change your card.")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(6)
                .shimmer(openPaymentPage)
            
            Spacer()
            
            Button(action: purchaseTapped) {
                if openPaymentPage {
                    CircleLoader(color: Color("TextPrimaryFixed"))
                        .frame(maxWidth: .infinity, maxHeight: 55)
                } else {
                    Text("Change")
                        .font(.body).bold()
                        .foregroundColor(Color("TextPrimaryFixed"))
                        .frame(maxWidth: .infinity, maxHeight: 55)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Accent"))
                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(Color("Border"), lineWidth: 2)
            )
            .sheet(item: $paymentUrl) { url in
                SafariView(url: url)
                    .onDisappear {
                        openPaymentPage = false
                        loadChangeDate()
                    }
            }
        }
        .padding(40)
        .overlay(alignment: .topLeading) {
            Button(action: {
                DispatchQueue.main.async {
                    dismiss()
                }
            }) {
                HStack (spacing: 0){
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(width: 16, height: 16)
                        .contentShape(Circle())
                    Text("back")
                        .font(.body)
                        .foregroundColor(Color("TextPrimary"))
                }
            }
            .padding(.top, 10)
            .padding(.leading, 10)
            .accessibilityLabel("Close")
        }
        .onAppear(){
            loadChangeDate()
        }
    }
    
    private func getInvoiceUrl() async throws -> String {
        let api = InvoiceApi()
        
        do{
            let url = try await api.getChangeCardUrl()
            return url.unquoted
        } catch{
            self.logger.e("Error get invoice url: \(error)", tag: self.LOG_TAG)
            throw error
        }
    }

    private func purchaseTapped() {
        openPaymentPage = true
        Task {
            do {
                let urlString = try await getInvoiceUrl()
                guard let url = URL(string: urlString) else {
                    logger.w("Incorrect invoice url: \(urlString)", tag: LOG_TAG)
                    return
                }
                await MainActor.run {
                    paymentUrl = url
                }
            } catch {
                logger.e("Error get invoice url: \(error)", tag: LOG_TAG)
            }
        }
    }
    
    private func saveChangeDate(){
        if let date = changePaymentDate {
            UserDefaults.standard.set(date, forKey: CHANGE_DATE_KEY)
        } else {
            UserDefaults.standard.removeObject(forKey: CHANGE_DATE_KEY)
        }
    }
    
    private func loadChangeDate() {
        isLoadingDate = true
        if UserDefaults.standard.object(forKey: CHANGE_DATE_KEY) != nil {
            if let data = UserDefaults.standard.data(forKey: CHANGE_DATE_KEY){
                self.changePaymentDate = try? JSONDecoder().decode(Date.self, from: data)
            }
        } else {
            self.changePaymentDate = nil
        }
        
        let invoiceApi = InvoiceApi()
        invoiceApi.getChangeDate() { result in
            switch result{
                case .success(let date):
                DispatchQueue.main.async {
                    self.changePaymentDate = date.dateChange
                }
            case .failure:
                break
            }
            isLoadingDate = false
        }
    }
}
