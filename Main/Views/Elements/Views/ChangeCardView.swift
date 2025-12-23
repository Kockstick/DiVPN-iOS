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
    
    @State var changePaymentDate: Date?
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
            
            Image("Paid")
                .resizable()
                .font(.system(size: 180, weight: .light))
                .frame(width: 180, height: 180)
                .foregroundColor(Color("TextPrimary"))
            
            Spacer()
                .frame(maxHeight: 15)
            
            Text("Change Card")
                .font(.largeTitle).bold()
                .foregroundColor(Color("TextPrimary"))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
                .frame(maxHeight: 30)
            
            Image("Divider")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 6)
                .foregroundColor(Color("TextSecondary"))
            
            Text("*Information may update with a short delay")
                .foregroundColor(Color("TextSecondary"))
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(maxHeight: 15)
            
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
            
            DrawButton(title: "Change", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: openPaymentPage){
                purchaseTapped()
            }
            .sheet(item: $paymentUrl) { url in
                SafariView(url: url)
                    .onDisappear {
                        openPaymentPage = false
                        isLoadingDate = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            loadChangeDate()
                        }
                    }
            }
        }
        .padding(40)
        .background {
            Image("Background")
                .resizable()
                .scaledToFill()
                .foregroundStyle(
                    Color("Background")
                )
                .ignoresSafeArea()
                .background(Color("DarkBackground"))
        }
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
    
    private func loadChangeDate() {
        DispatchQueue.main.async { self.isLoadingDate = true }

        if let date = DiStorage.loadChangeDate() {
            self.changePaymentDate = date
        } else {
            self.changePaymentDate = nil
        }

        let invoiceApi = InvoiceApi()
        invoiceApi.getChangeDate { result in
            switch result {
            case .success(let date):
                DispatchQueue.main.async {
                    self.changePaymentDate = date.dateChange
                    self.isLoadingDate = false
                    DiStorage.saveChangeDate(date: date.dateChange)
                }
            case .failure:
                DispatchQueue.main.async {
                    self.isLoadingDate = false
                }
            }
        }
    }
}
