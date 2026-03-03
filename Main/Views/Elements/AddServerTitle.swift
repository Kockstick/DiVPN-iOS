//
//  AddServerTitle.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 28.02.2026.
//

import SwiftUI

struct AddServerTitle: View {
    var body: some View {
        HStack{
            Text("Add and manage your Outline server")
                .font(.title3).bold()
                .foregroundColor(Color("TextPrimary"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            Image("ShowArrow")
                .resizable()
                .frame(width: 100, height: 50)
                .foregroundColor(Color("TextPrimary"))
                .rotationEffect(Angle(degrees: 180))
        }
    }
}
