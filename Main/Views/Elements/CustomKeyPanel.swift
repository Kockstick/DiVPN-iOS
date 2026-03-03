//
//  CustomKeyView.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 24.02.2026.
//

import SwiftUI

struct CustomKeyPanel: View {
    
    @StateObject var km: SideKeyManager
    
    var isFocused: FocusState<Bool>.Binding?
    
    @State var urlKey: String = ""
    @State var isValidKey = false
    @State var showDeleteConfirm: Bool = false
    
    var body: some View {
        VStack{
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 2)
                .foregroundColor(Color("TextSecondary"))
            
            Text("custom key")
                .foregroundColor(Color("TextPrimary"))
                .font(.body).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 5)
            
            if km.customKey != nil {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(Color("TextSecondary"))
                    .opacity(0.2)
                HStack(spacing: 10){
                    RadioButton(isSelected: km.selected?.password == km.customKey?.password)
                        .onTapGesture {
                            km.selected = km.customKey
                        }
                    
                    Text(km.customKey!.name ?? "Custom Key")
                        .font(.body).bold()
                        .foregroundStyle(Color("TextPrimary"))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            km.selected = km.customKey
                        }
                    
                    Button{
                        showDeleteConfirm = true
                    } label:{
                        Image("Delete")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("ForceError"))
                            .padding(.horizontal, 10)
                    }
                    .confirmationDialog("Are you shure?", isPresented: $showDeleteConfirm) {
                        Button("Delete", role: .destructive) {
                            if let s = km.customKey {
                                if km.selected != nil && km.selected!.password == s.password {
                                    km.selected = nil
                                }
                                km.customKey = nil
                            }
                        }
                        Button("Cansel", role: .cancel) {}
                    }
                }
                .padding(.vertical, 10)
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(Color("TextSecondary"))
                    .opacity(0.2)
            } else{
                HStack (spacing: 10){
                    DiTextField(text: $urlKey, prompt: "ss://...", isFocused: isFocused){ value in
                        isValidKey = validateKey(urlKey)
                    }
                    
                    if(isValidKey){
                        Button{
                            guard let key = parseOutlineKey(from: urlKey) else { return }
                            km.customKey = key
                        } label: {
                            Image("Save")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("Accent"))
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
    
    private func validateKey(_ key: String) -> Bool {
        guard key.hasPrefix("ss://") else { return false }
        
        let raw = key.dropFirst(5) // убираем ss://
        
        // убираем якорь имени (#Name)
        let mainPart = raw.split(separator: "#", maxSplits: 1).first ?? ""
        
        // делим на креды и хост
        guard let atIndex = mainPart.firstIndex(of: "@") else {
            return false
        }
        
        let credentialsPart = String(mainPart[..<atIndex])
        let hostPart = String(mainPart[mainPart.index(after: atIndex)...])
        
        // проверяем host:port
        let hostAndQuery = hostPart.split(separator: "/", maxSplits: 1).first ?? ""
        let hostComponents = hostAndQuery.split(separator: ":")
        
        guard hostComponents.count == 2,
              Int(hostComponents[1]) != nil else {
            return false
        }
        
        // base64 decode credentials
        guard let decodedData = Data(base64Encoded: credentialsPart),
              let decodedString = String(data: decodedData, encoding: .utf8),
              decodedString.contains(":") else {
            return false
        }
        
        return true
    }
    
    private func parseOutlineKey(from key: String) -> OutlineKey? {
        guard key.hasPrefix("ss://") else { return nil }
        
        let raw = key.dropFirst(5)
        
        // убираем якорь (#Name), если есть
        let mainPart = raw.split(separator: "#", maxSplits: 1).first ?? ""
        
        // делим на credentials и host
        guard let atIndex = mainPart.firstIndex(of: "@") else {
            return nil
        }
        
        let credentialsPart = String(mainPart[..<atIndex])
        let hostPart = String(mainPart[mainPart.index(after: atIndex)...])
        
        // декодируем method:password
        guard
            let decodedData = Data(base64Encoded: credentialsPart),
            let decodedString = String(data: decodedData, encoding: .utf8)
        else {
            return nil
        }
        
        let creds = decodedString.split(separator: ":", maxSplits: 1)
        guard creds.count == 2 else { return nil }
        
        let method = String(creds[0])
        let password = String(creds[1])
        
        // убираем query часть (/?outline=1 и т.п.)
        let hostPortPart = hostPart
            .split(separator: "/", maxSplits: 1)
            .first
            .map(String.init) ?? ""
        
        let hostComponents = hostPortPart.split(separator: ":")
        guard hostComponents.count == 2,
              let port = Int(hostComponents[1])
        else {
            return nil
        }
        
        let ip = "IP: " + String(hostComponents[0])
        
        return OutlineKey(
            id: UUID().uuidString,
            name: ip,
            password: password,
            port: port,
            method: method,
            dataLimit: nil,
            accessUrl: key,
            usedBytes: 0
        )
    }
}
