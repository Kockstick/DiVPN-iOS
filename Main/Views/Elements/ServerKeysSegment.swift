//
//  ServerKeysSegment.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 26.02.2026.
//

import SwiftUI

struct ServerKeysSegment: View {
    @Binding var selected: OutlineServerApi?
    @StateObject var sm: OutlineServersManager
    @StateObject var km: SideKeyManager
    
    @State private var showKeyView: Bool = false
    @State private var openKey: OutlineKey?
    
    var body: some View {
        ScrollView{
            VStack{
                if(sm.isLoadingKeys){
                    CircleLoader(color: Color("TextPrimary"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel(Text("Loading"))
                } else{
                    ForEach(sm.keys.indices, id: \.self) { index in
                        let key = sm.keys[index]
                        
                        KeyItem(
                            index: index,
                            key: key,
                            isSelected: km.selected?.password == key.password,
                            onTap: {
                                if key.id != "0" {
                                    openKey = key
                                    showKeyView = true
                                }
                            },
                            onSelect: {
                                km.selected = key
                            }
                        )
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(Color("TextSecondary"))
                            .opacity(0.2)
                    }
                    
                    HStack(spacing: 10){
                        Text("Add key")
                            .font(.body).bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color("Accent"))
                    }
                    .overlay(alignment: .leading){
                        Image(systemName: "plus")
                            .font(.body).bold()
                            .foregroundStyle(Color("Accent"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .onTapGesture {
                        if let server = sm.selected{
                            km.create(server){ key in
                                if let key = key{
                                    sm.loadKeys()
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showKeyView) {
                KeyView(sm: sm, km: km, key: openKey!)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 15)
        }
    }
}
