//
//  SupportView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 24.08.2025.
//

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
                
                Spacer()
                    .frame(maxHeight: 20)
                
                Text("DiVPN.Service@gmail.com")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
                
                Spacer()
                
                Text("Maybe someone will actually reply to you.")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 15)
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .lineSpacing(8)
                
                Button(action: {
                    UIPasteboard.general.string = "DiVPN.Support@gmail.com"
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }) {
                    Text("Copy and close")
                        .font(.system(size: 16, weight: .bold))
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
    }
}
