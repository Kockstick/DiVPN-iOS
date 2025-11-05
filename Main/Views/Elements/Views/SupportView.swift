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
    
    private let supportEmail = "Support@divpn.ru"
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                    .frame(maxHeight: 50)
                
                Image("Support")
                    .resizable()
                    .frame(width: 250, height: 230)
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                    .frame(maxHeight: 30)
                
                Image("Divider")
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 6)
                    .foregroundColor(Color("TextSecondary"))
                
                Spacer()
                    .frame(maxHeight: 30)
                
                Text("Email for support:")
                    .font(.title2).bold()
                    .foregroundColor(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
                
                Spacer()
                    .frame(maxHeight: 10)
                
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
                
                DrawButton(title: "Copy", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: false){
                    haptic.notificationOccurred(.success)

                    UIPasteboard.general.setItems(
                        [[UIPasteboard.typeAutomatic: supportEmail]],
                        options: [.localOnly: true]
                    )
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dismiss()
                    }
                }
            }
            .padding(40)
            .padding(.bottom, 10)
            .padding(.top, 30)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onAppear { haptic.prepare() }
    }
}
