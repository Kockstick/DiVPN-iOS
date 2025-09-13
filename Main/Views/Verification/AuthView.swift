//
//  AuthView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 26.08.2025.
//

import SwiftUI

struct AuthView: View{
    @EnvironmentObject var auth: AuthState
    @State private var path: [AuthRoute] = [.email]
    
    var body: some View{
        NavigationStack(path: $path) {
            Color.clear
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .email:
                        EmailView {
                            path.append(.code)
                        }
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                        
                    case .code:
                        CodeView {
                            auth.isAuthorized = true
                        }
                        .navigationBarHidden(true)
                    }
                }
        }
        // Важно: в корне cover нет крестика/свайпа, пользователь не "убежит" в Main
        .interactiveDismissDisabled(true)
    }
}

// 1) Состояние авторизации
final class AuthState: ObservableObject {
    @Published var isAuthorized = true
}

// 2) Маршруты ТОЛЬКО для auth-флоу
enum AuthRoute: Hashable {
    case email
    case code
}
