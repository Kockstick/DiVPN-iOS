//
//  AddServerView.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 24.02.2026.
//

import SwiftUI

struct AddServerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var sm: OutlineServersManager
    var onAdded: (_ newServer: OutlineServerApi) -> Void
    
    var body: some View {
        VStack{
            AddServerTitle()
            
            AddServerSegment(){ server in
                sm.selected = server
                onAdded(server)
                dismiss()
            }
            
            Spacer()
        }
        .padding(.top, 30)
        .padding(.horizontal, 40)
        .padding(.vertical, 70)
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
}
