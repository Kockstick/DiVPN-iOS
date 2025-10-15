import SwiftUI

struct PurchasePanel: View {
    @StateObject var tariffManager = TariffManager.shared
    
    // Внешние зависимости
    @StateObject var agreementManager = AgreementManager.shared
    @State var openPaymentPage: Bool = false
    @State var showErrorLine: Bool = false
    @State private var paymentUrl: URL?
    @State var showPrice: Bool
    @State var showSafariView: Bool = false
    @State var showPublicOffer: Bool = false
    
    private let LOG_TAG = "ShopView"
    private let logger = DiLogger.shared

    var body: some View {
        VStack(spacing: 0) {
            if(showPrice){
                HStack{
                    Text(tariffManager.subscribtionPriceText)
                        .font(.largeTitle).bold()
                        .frame(alignment: .leading)
                        .shimmer(tariffManager.subscribtionPrice == nil)
                    Text("for 1 month")
                        .font(.title2).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .frame(alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Toggle(isOn: $agreementManager.isPublicOfferAgreed) {
                    EmptyView()
                }
                .toggleStyle(CheckboxToggleStyle())
                .frame(width: 35, height: 35)
                .disabled(openPaymentPage)
                .onChange(of: agreementManager.isPublicOfferAgreed) { _ in
                    showErrorLine = false
                }

                Text(attributedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote).bold()
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
                    .onTapGesture {
                        if let range = attributedText.range(of: NSLocalizedString("offer_terms", comment: "")) {
                            showPublicOffer = true
                        }
                    }
                    .sheet(isPresented: $showPublicOffer) {
                        SafariView(url: URL(string: Bundle.main.publicOfferUrl)!)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)

            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color("Error"))
                .opacity(showErrorLine ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: showErrorLine)

            Spacer().frame(maxHeight: 15)

            Button(action: purchaseTapped) {
                if openPaymentPage {
                    CircleLoader(color: Color("TextPrimaryFixed"))
                        .frame(maxWidth: .infinity, maxHeight: 55)
                } else {
                    Text("Purchase subscription")
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
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("Border"), lineWidth: 2)
            )
            .opacity(showErrorLine ? 0.4 : 1)
            .compositingGroup()
        }
        .sheet(item: $paymentUrl) { url in
            SafariView(url: url)
                .onDisappear {
                    openPaymentPage = false
                }
        }
    }
    
    private func getInvoiceUrl() async throws -> String {
        let api = InvoiceApi()
        
        do{
            let url = try await api.getInvoiceUrl()
            return url.unquoted
        } catch{
            self.logger.e("Error get invoice url: \(error)", tag: self.LOG_TAG)
            throw error
        }
    }

    private func purchaseTapped() {
        if !agreementManager.isPublicOfferAgreed {
            if showErrorLine { return }
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            showErrorLine = true
            return
        }

        openPaymentPage = true
        Task {
            do {
                let urlString = try await getInvoiceUrl()
                guard let url = URL(string: urlString) else {
                    logger.w("Incorrect invoice url: \(urlString)", tag: "PurchasePanel")
                    return
                }
                await MainActor.run { paymentUrl = url }
            } catch {
                logger.e("Error get invoice url: \(error)", tag: "PurchasePanel")
            }
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}

private var attributedText: AttributedString {
    var result = AttributedString(NSLocalizedString("offer_terms_text", comment: ""))
    if let range = result.range(of: NSLocalizedString("offer_terms", comment: "")) {
        result[range].foregroundColor = .blue
        result[range].underlineStyle = .single
    }
    return result
}
