//
//  UnsubscribeView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 05.10.2025.
//

import SwiftUI

struct UnsubscribeView: View{
    @Environment(\.dismiss) private var dismiss
    private let haptic = UINotificationFeedbackGenerator()
    @State var selection: ReasonUnsubscribe?
    
    private let invoiceApi = InvoiceApi()
    
    @Binding var loading: Bool
    
    var body: some View{
        VStack{
            Spacer()
                .frame(maxHeight: 10)
            
            Text("Why do you want to cansel your subscription?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title).bold()
                .multilineTextAlignment(.leading)
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(10)
            
            Spacer()
                .frame(maxHeight: 40)
            
            Image("Divider")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 6)
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
                .frame(maxHeight: 40)
            
            radioRow(isSelected: selection == .NotUsing, title: NSLocalizedString("not_using", comment:"")) {
                selection = .NotUsing
            }
            Spacer()
                .frame(maxHeight: 8)
            radioRow(isSelected: selection == .TooExpensive, title: NSLocalizedString("too_expensive", comment:"")) {
                selection = .TooExpensive
            }
            Spacer()
                .frame(maxHeight: 8)
            radioRow(isSelected: selection == .UnstableConnection, title: NSLocalizedString("unstable_connection", comment:"")) {
                selection = .UnstableConnection
            }
            Spacer()
                .frame(maxHeight: 8)
            radioRow(isSelected: selection == .AppIssues, title: NSLocalizedString("app_issues", comment:"")) {
                selection = .AppIssues
            }
            Spacer()
                .frame(maxHeight: 8)
            radioRow(isSelected: selection == .Other, title: NSLocalizedString("other", comment:"")) {
                selection = .Other
            }
            
            Spacer()
            
            DrawButton(title: "Confirm", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: loading){
                loading = true
                haptic.notificationOccurred(.success)
                invoiceApi.canselSubscribtion(selection!){_ in
                    TariffManager.shared.loadTariff() {_ in
                        loading = false
                    }
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    dismiss()
                }
            }
            .disabled(selection == nil)
            .opacity(selection == nil ? 0.5 : 1)
        }
        .padding(.horizontal, 40)
        .padding(.top, 70)
        .padding(.bottom, 50)
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
    }
    
    @ViewBuilder
    func radioRow(isSelected: Bool, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RadioButton(isSelected: isSelected)
                Text(title)
                    .frame(alignment: .leading)
                    .font(.title3).bold()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color("TextPrimary"))
                Spacer(minLength: 0)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onAppear { haptic.prepare() }
    }
}
