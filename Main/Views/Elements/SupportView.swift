//
//  SupportView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 24.08.2025.
//

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    private let haptic = UINotificationFeedbackGenerator()
    
    private let supportEmail = "DiVPN.Service@gmail.com"
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                    .frame(maxHeight: 50)
                
                Image("support")
                    .font(.system(size: 230, weight: .thin))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                    .frame(maxHeight: 30)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
                    .foregroundColor(Color("TextSecondary"))
                
                Spacer()
                    .frame(maxHeight: 30)
                
                Text("Email for support:")
                    .font(.title2).bold()
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
                
                Spacer()
                    .frame(maxHeight: 20)
                
                Text(supportEmail)
                    .font(.title2).bold()
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
                
                Spacer()
                
                Text("Maybe someone will actually reply to you.")
                    .font(.footnote)
                    .padding(.horizontal, 15)
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .lineSpacing(8)
                
                Button(action: {
                    haptic.notificationOccurred(.success)

                    UIPasteboard.general.setItems(
                        [[UIPasteboard.typeAutomatic: supportEmail]],
                        options: [.localOnly: true]
                    )
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dismiss()
                    }
                }) {
                    Text("Copy and close")
                        .font(.body).bold()
                        .foregroundColor(Color("TextPrimaryFixed"))
                        .frame(maxWidth: .infinity, maxHeight: 55)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("Accent"))
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(Color("Border"), lineWidth: 2)
                )
                .compositingGroup()
            }
            .padding(40)
            .padding(.bottom, 10)
            .padding(.top, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        .onAppear { haptic.prepare() }
    }
}
