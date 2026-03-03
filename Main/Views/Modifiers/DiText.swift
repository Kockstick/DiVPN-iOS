//
//  DiText.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 01.03.2026.
//

import SwiftUI

struct DiText: View {
    var text: String
    var upnote: String
    
    var body: some View {
        VStack{
            if(upnote != ""){
                UpNote(text: upnote, textColor: Color("TextPrimaryFixed"), borderColor: Color("TextSecondary"), isFocused: false)
            }
            
            ZStack{
                Text(text)
                    .foregroundStyle(Color("TextPrimary"))
                    .font(.body).bold()
                    .textSelection(.enabled)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("TextSecondary"), lineWidth: 2)
                    .background(Color("Surface"))
                    .opacity(0.3)
            )
        }
    }
}
