//
//  ManagerServersView.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 24.02.2026.
//

import SwiftUI

struct ManagerServersView: View {
    @Environment(\.dismiss) private var dismiss
    @State var manager: OutlineServersManager
    
    @State var showAddServerView: Bool = false
    
    var onSelect: (_ id: UUID) -> Void
    
    var body: some View {
        ScrollView{
            VStack{
                ForEach(Array(manager.servers.enumerated()), id: \.element.id) { index, server in
                    ServerItem(
                        id: server.id,
                        name: server.name)
                    .onTapGesture {
                        onSelect(server.id)
                        dismiss()
                    }
                }
                
                VStack{
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("Accent"))
                        .opacity(0.2)
                    
                    HStack(spacing: 10){
                        Text("Add server")
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
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color("Accent"))
                        .opacity(0.2)
                }
                .onTapGesture {
                    showAddServerView = true
                }
                .sheet(isPresented: $showAddServerView){
                    AddServerView(sm: manager){ server in
                        onSelect(server.id)
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 70)
        }
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
    }
}
