//
//  OptionsInfo.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 19.01.2026.
//

import SwiftUI

struct OptionsInfo: View{
    @StateObject var ssManager: ShadowsocksManager
    @Binding var user: User?
    
    var body: some View{
        HStack(spacing: 15){
            Image("VerticalDivider")
                .resizable()
                .frame(width: 6, height: 70)
                .foregroundColor(Color("TextSecondary"))
                
            VStack{
                Text(user?.email ?? "user")
                    .foregroundColor(Color("TextSecondary"))
                    .font(.body).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                Text(ssManager.serverLocation ?? "• • • • • •")
                    .font(.largeTitle).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color("TextSecondary"))
                    //.shimmer(ssManager.serverLocation == nil, color: Color("TextSecondary"))
            }
            .padding(.vertical, 5)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
