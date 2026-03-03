//
//  ManagerView.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 24.02.2026.
//

import SwiftUI

struct ManagerView: View {
    @State private var segment: Int = 0
    @StateObject var sm = OutlineServersManager.shared
    @StateObject var km = SideKeyManager.shared
    @State private var didAppear = false
    
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isCustomKeyPanelFocused: Bool
    
    var body: some View {
        VStack{
            VStack{
                ManagerServersPanel(segment: $segment, selected: $sm.selected, serversManager: sm)
                
                switch segment{
                case 0:
                    AddServerSegment(){ server in
                        segment = 1
                        sm.selected = server
                    }
                case 1:
                    ServerKeysSegment(selected: $sm.selected, sm: sm, km: km)
                case 2:
                    ServerOptionsSegment(selected: $sm.selected, manager: sm){
                        segment = 1
                    }
                default:
                    Text("")
                }
                
                Spacer()
                
                CustomKeyPanel(km: km, isFocused: $isCustomKeyPanelFocused)
            }
            .offset(y: isCustomKeyPanelFocused ? -keyboardHeight : 0)
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
        }
        .onAppear{
            guard !didAppear else { return }
                didAppear = true
            
            sm.refresh()
            sm.restoreSelected()
            segment = sm.selected == nil ? 0 : 1
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    let screenHeight = UIScreen.main.bounds.height
                    keyboardHeight = max(0, screenHeight - frame.origin.y - 60)
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 70)
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
