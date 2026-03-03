//
//  ServerOptionsSegment.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 26.02.2026.
//

import SwiftUI

struct ServerOptionsSegment: View {
    @Binding var selected: OutlineServerApi?
    @State var manager: OutlineServersManager
    
    @State private var showConfirmDelete = false
    @State private var isChanged: Bool = false
    
    @FocusState private var nameFocused: Bool
    
    var onChange: () -> Void
    
    var body: some View {
        VStack{
            UpNote(text: "Name", textColor: Color("TextPrimaryFixed"), borderColor: selected?.name == "" ? Color("Error") : nameFocused ? Color("Active") : Color("TextSecondary"), isFocused: nameFocused)
                .onTapGesture {
                    nameFocused = true
                }
            
            if let _ = selected {
                TextField("", text: Binding(get: { selected?.name ?? "" }, set: { selected?.name = $0 }), prompt: Text("My favorite server").foregroundColor(Color("TextSecondary")))
                    .frame(height: 55)
                    .padding(.horizontal, 16)
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($nameFocused)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selected?.name == "" ? Color("Error") :nameFocused ? Color("Active") : Color("TextSecondary"), lineWidth: 2)
                    )
                    .animation(.easeInOut(duration: 0.18), value: nameFocused)
                    .foregroundColor(Color("TextPrimary"))
                    .font(.title3).bold()
                    .minimumScaleFactor(0.8)
                    .contentShape(Rectangle())
                    .onChange(of: selected?.name) { newValue in
                        isChanged = true
                    }
            }
            
            DiText(text: selected?.apiUrl ?? "", upnote: "API key")
            
            if(selected?.name != "" && isChanged){
                DrawButton(title: "Save", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: false){
                    if let s = selected {
                        manager.save(s)
                        manager.refresh()
                        isChanged = false
                    }
                }
            }
            
            DrawButton(title: "Remove", bgColor: Color("Error"), textColor: Color("TextPrimaryFixed"), isLoading: false){
                showConfirmDelete = true;
            }
            .confirmationDialog("Are you shure?", isPresented: $showConfirmDelete) {
                Button("Delete", role: .destructive) {
                    if let s = selected {
                        manager.delete(s)
                        manager.refresh()
                        manager.selectFirstIfExist()
                        onChange()
                    }
                }
                Button("Cansel", role: .cancel) {}
            }
        }
    }
}
