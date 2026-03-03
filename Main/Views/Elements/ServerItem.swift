//
//  ServerItem.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 24.02.2026.
//

import SwiftUI

struct ServerItem: View {
    @State var id: UUID
    @State var name: String
    
    var body: some View {
        VStack{
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .foregroundColor(Color("TextSecondary"))
                .opacity(0.2)
            
            HStack{
                Text(name)
                    .font(.body).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("TextPrimary"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }
}
