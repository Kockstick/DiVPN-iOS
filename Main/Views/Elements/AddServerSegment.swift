//
//  AddServerPromo.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 24.02.2026.
//

import SwiftUI

struct AddServerSegment: View {
    @StateObject var vm = AddServerViewModel()
    
    var onAdded: (_ newServer: OutlineServerApi) -> Void
    
    @FocusState private var nameFocused: Bool
    @FocusState private var apiFocused: Bool
    
    var body: some View {
        VStack{
            
            UpNote(text: "Name", textColor: Color("TextPrimaryFixed"), borderColor: !vm.isNameValid ? Color("Error") : nameFocused ? Color("Active") : Color("TextSecondary"), isFocused: nameFocused)
                .onTapGesture {
                    nameFocused = true
                }
            
            
            TextField("", text: $vm.name, prompt: Text("My favorite server").foregroundColor(Color("TextSecondary")))
                .frame(height: 55)
                .padding(.horizontal, 16)
                .cornerRadius(10)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($nameFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(!vm.isNameValid ? Color("Error") :nameFocused ? Color("Active") : Color("TextSecondary"), lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.18), value: nameFocused)
                .foregroundColor(Color("TextPrimary"))
                .font(.title3).bold()
                .minimumScaleFactor(0.8)
                .contentShape(Rectangle())
            
            UpNote(text: "API key", textColor: Color("TextPrimaryFixed"), borderColor: vm.isApiError ? Color("Error") :apiFocused ? Color("Active") : Color("TextSecondary"), isFocused: apiFocused)
                .onTapGesture {
                    nameFocused = true
                }
            
            TextField("", text: $vm.apiKey, prompt: Text("https://xxx.xxx.xxx.xxx:xxxxx/xxxxxxxxxxxxxxxxxxxxxx").foregroundColor(Color("TextSecondary")))
                .frame(height: 55)
                .padding(.horizontal, 16)
                .cornerRadius(10)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($apiFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(vm.isApiError ? Color("Error") :apiFocused ? Color("Active") : Color("TextSecondary"), lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.18), value: apiFocused)
                .foregroundColor(Color("TextPrimary"))
                .font(.title3).bold()
                .minimumScaleFactor(0.8)
                .contentShape(Rectangle())
            
            if(vm.apiKey != "" && vm.isFormValid && vm.isNameValid){
                DrawButton(title: "Add server", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: false){
                    let newServer = vm.addServer(vm.name, vm.apiKey)
                    onAdded(newServer)
                }
                .padding(.top, 20)
            }
        }
        .padding(.vertical, 20)
    }
}
