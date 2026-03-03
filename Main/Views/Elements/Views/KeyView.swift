//
//  KeyView.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 28.02.2026.
//

import SwiftUI

struct KeyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var sm: OutlineServersManager
    var km: SideKeyManager
    var key: OutlineKey
    
    @State var newName: String = ""
    @State var isChanged: Bool = false
    @State var loadingRename: Bool = false
    @State var loadingDelete: Bool = false
    @State var showConfirmDelete: Bool = false
    
    init(sm: OutlineServersManager, km: SideKeyManager, key: OutlineKey) {
        self.sm = sm
        self.km = km
        self.key = key
        _newName = State(initialValue: key.name ?? "")
    }
    
    var body: some View {
        VStack(spacing: 15){
            Text("Outline key")
                .font(.largeTitle).bold()
                .foregroundStyle(Color("TextPrimary"))
                .frame(maxWidth: .infinity, alignment: .center)
            
            DiTextField(text: $newName, prompt: "Key \(key.id)", upnote: "Name"){ value in
                isChanged = true
            }
            .padding(.top, 20)
            
            DiText(text: key.accessUrl, upnote: "Access key")
            
            if(isChanged){
                DrawButton(title: "Save", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: loadingRename){
                    if let server = sm.selected{
                        loadingRename = true
                        km.rename(key, newName, server){
                            loadingRename = false
                            isChanged = false
                            dismiss()
                        }
                    }
                }
            }
            
            DrawButton(title: "Delete", bgColor: Color("Error"), textColor: Color("TextPrimaryFixed"), isLoading: loadingDelete){
                showConfirmDelete = true;
            }
            .confirmationDialog("Are you shure?", isPresented: $showConfirmDelete) {
                Button("Delete", role: .destructive) {
                    if let server = sm.selected{
                        loadingDelete = true
                        km.delete(key, server){
                            Task { @MainActor in
                                if let selectedKey = km.selected,
                                   selectedKey.password == key.password {
                                    km.selected = nil
                                }
                                loadingDelete = false
                                dismiss()
                            }
                        }
                    }
                }
                Button("Cansel", role: .cancel) {}
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 70)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .overlay(alignment: .topLeading) {
            Button(action: {
                DispatchQueue.main.async {
                    dismiss()
                }
            }) {
                HStack (spacing: 0){
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(width: 16, height: 16)
                        .contentShape(Circle())
                    Text("back")
                        .font(.body)
                        .foregroundColor(Color("TextPrimary"))
                }
            }
            .padding(.top, 10)
            .padding(.leading, 10)
            .accessibilityLabel("Close")
        }
    }
}
