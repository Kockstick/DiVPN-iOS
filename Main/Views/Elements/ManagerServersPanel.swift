//
//  ManagerServersPanel.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 24.02.2026.
//

import SwiftUI

struct ManagerServersPanel: View {
    
    @Binding var segment: Int
    @Binding var selected: OutlineServerApi?
    
    var serversManager: OutlineServersManager
    
    @State private var showServersView = false
    
    var body: some View {
            if selected == nil {
                AddServerTitle()
            } else{
                Button{
                    showServersView = true
                } label: {
                    HStack(spacing: 20){
                        Text(selected?.name ?? "• • • • •")
                            .font(.title3).bold()
                            .foregroundColor(Color("TextPrimary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 55)
                    .padding(.horizontal, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("TextSecondary"), lineWidth: 2)
                            .background(Color("Surface"))
                            .opacity(0.3)
                    )
                }
                .sheet(isPresented: $showServersView){
                    ManagerServersView(manager: serversManager){ id in
                        selected = serversManager.servers.first(where: { $0.id == id })
                    }
                }
                
                Picker("Select", selection: $segment) {
                    Text("Keys").tag(1)
                    Text("Options").tag(2)
                }
                .pickerStyle(.segmented)
            }
    }
}
