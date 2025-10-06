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
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.leading)
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(12)
            
            Spacer()
                .frame(maxHeight: 40)
            
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 2)
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
                .frame(maxHeight: 40)
            
            radioRow(isSelected: selection == .NotUsing, title: "Not using") {
                selection = .NotUsing
            }
            radioRow(isSelected: selection == .TooExpensive, title: "Too expensive") {
                selection = .TooExpensive
            }
            radioRow(isSelected: selection == .UnstableConnection, title: "Unstable connection") {
                selection = .UnstableConnection
            }
            radioRow(isSelected: selection == .AppIssues, title: "App issues") {
                selection = .AppIssues
            }
            radioRow(isSelected: selection == .Other, title: "Other") {
                selection = .Other
            }
            
            Spacer()
            
            Button(action: {
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
            }) {
                Text("Confirm")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("TextPrimaryFixed"))
                    .frame(maxWidth: .infinity, maxHeight: 55)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Error"))
                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("Border"), lineWidth: 2)
            )
            .disabled(selection == nil)
            .opacity(selection == nil ? 0.5 : 1)
        }
        .padding(.horizontal, 40)
        .padding(.top, 70)
        .padding(.bottom, 50)
    }
    
    @ViewBuilder
    func radioRow(isSelected: Bool, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RadioButton(isSelected: isSelected)
                Text(title)
                    .frame(alignment: .leading)
                    .font(.system(size: 24, weight: .bold))
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
