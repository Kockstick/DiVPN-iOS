//
//  RateView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 13.09.2025.
//
//вцу

import SwiftUI

struct PromocodeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    private let haptic = UINotificationFeedbackGenerator()
    
    @StateObject private var viewModel = PromocodeViewModel()
    @FocusState private var isFocused: Bool
    @State var text: String = ""
    
    private var userApi = UserApi()
    
    private let LOG_TAG = "PromocodeView"
    private let logger = DiLogger.shared
    
    var body: some View {
        ZStack{
            ZStack{
                VStack{
                    Spacer()
                        .frame(maxHeight: 30)
                    
                    Text("Got a promo code?\nDrop it here.")
                        .font(.title).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    TextField("", text: $text, prompt: Text("Type here...").foregroundColor(Color("TextSecondary")))
                        .frame(height: 55)
                        .padding(.horizontal, 16)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isFocused ? Color(!viewModel.loading ? "Active" : "Surface") : Color("Border"), lineWidth: 2)
                        )
                        .foregroundColor(Color("TextPrimary"))
                        .font(.title3).bold()
                        .contentShape(Rectangle())
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: {
                        isFocused = false
                        viewModel.loading = true
                        
                        userApi.usePromo(text: text) { result in
                            switch result {
                            case .success(let data):
                                haptic.notificationOccurred(.success)
                                DispatchQueue.main.async {
                                    viewModel.loading = false
                                }
                                dismiss()
                            case .failure(let error):
                                haptic.notificationOccurred(.error)
                                DispatchQueue.main.async {
                                    viewModel.loading = false
                                }
                            }
                        }
                    }) {
                        Text("Send")
                            .font(.body).bold()
                            .foregroundColor(Color("TextPrimaryFixed"))
                            .frame(maxWidth: .infinity, maxHeight: 55)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Accent"))
                            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("Border"), lineWidth: 2)
                    )
                    .compositingGroup()
                }
                .padding(40)
                .padding(.bottom, 10)
                .padding(.top, 30)
                CircleLoader(color: Color("TextPrimary"), size: 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("Background"))
                    .opacity(viewModel.loading ? 1 : 0)
                    .animation(.easeInOut(duration: 0.18), value: viewModel.loading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
            .onAppear { haptic.prepare() }
            .overlay(alignment: .topLeading) {
                Button(action: {
                    logger.i("Back tapped → dismiss()", tag: LOG_TAG)
                    dismiss()
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
}
