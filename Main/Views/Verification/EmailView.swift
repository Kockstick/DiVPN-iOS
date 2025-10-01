//
//  EmailView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 07.08.2025.
//

import SwiftUI

struct EmailView: View {
    var onNext: () -> Void
    
    @StateObject var viewModel = EmailViewModel()
    @StateObject var agreementManager = AgreementManager.shared
    @State var isValid: Bool = false
    @State var showPrivacyPolicy: Bool = false
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            VStack{
                DiHeader(title: "Sign in", subtitle: "Email", isAnimated: viewModel.loading)
                    .frame(alignment: .top)
                Spacer()
                ZStack{
                    TextField("", text: $viewModel.email, prompt: Text("Your email").foregroundColor(Color("TextSecondary")))
                        .frame(height: 55)
                        .padding(.horizontal, 16)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isFocused ? Color("Active") : Color("Border"), lineWidth: 2)
                        )
                        .animation(.easeInOut(duration: 0.18), value: isFocused)
                        .foregroundColor(Color("TextPrimary"))
                        .font(.system(size: 20, weight: .bold))
                        .contentShape(Rectangle())
                        .opacity(viewModel.loading ? 0.5 : 2)
                        .onChange(of: viewModel.email) { newValue in
                            if viewModel.errMessage != nil {
                                var isValidEmail: Bool = viewModel.validateEmail(newValue)
                                if isValidEmail {
                                    viewModel.errMessage = nil
                                }
                            }
                            
                            isValid = newValue.contains("@") && newValue.contains(".")
                            viewModel.loading = false
                        }
                }
                .onTapGesture {
                    isFocused = true
                }
                HStack(spacing: 1){
                    if(viewModel.errMessage != nil){
                        Image("error")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color("Error"))
                    }
                    Text(viewModel.errMessage == nil ? NSLocalizedString("create_account_hint", comment: "") : viewModel.errMessage!)
                        .font(.system(size: 12))
                }
                .shimmer(viewModel.loading)
                
                Spacer()
                
                HStack{
                    Toggle(isOn: $agreementManager.isPrivacyPolicyAccept) {
                        EmptyView()
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .frame(width: 25, height: 25)
                    .disabled(viewModel.loading)
                    
                    Text("I agree to the")
                        .foregroundColor(Color("TextPrimary"))
                        .font(.system(size: 16))
                    
                    Button(action: {
                        showPrivacyPolicy = true
                    }){
                        HStack{
                            Text("Privacy Policy")
                                .font(.system(size: 16))
                        }
                    }
                    .sheet(isPresented: $showPrivacyPolicy) {
                        SafariView(url: URL(string: Bundle.main.privacyPolicyUrl)!)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                
                Spacer()
                    .frame(maxHeight: 15)
                
                Button(action: {
                    viewModel.onButtonClick(){ success in
                        if success {
                            onNext()
                        }
                    }
                }) {
                    HStack(spacing: 2){
                        Text(viewModel.loading ? "Waiting for server response" : "Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("TextPrimaryFixed"))
                        
                        if(!viewModel.loading){
                            Image("double_arrow")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("TextPrimaryFixed"))
                        }
                    }
                    .opacity(colorScheme == .dark ? 1 : viewModel.loading ? 0.3 : isValid ? 1 : 0.3)
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .disabled(viewModel.loading || !isValid)
                    .background(
                        Color(!viewModel.loading && agreementManager.isPrivacyPolicyAccept ? viewModel.errMessage == nil ? "Accent" : "Error" : "Surface")
                            .cornerRadius(12)
                            .shadow(  // Переносим тень в background
                                color: .black.opacity(viewModel.loading || !agreementManager.isPrivacyPolicyAccept ? 0 : isValid ? 0.15 : 0),
                                radius: 5,
                                x: 0,
                                y: 5
                                   )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("Border"), lineWidth: 2)
                    )
                }
                .disabled(viewModel.loading || !isValid || viewModel.errMessage != nil || !agreementManager.isPrivacyPolicyAccept)
                .contentShape(Rectangle())
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            }
            .frame(alignment: .top)
            .padding([.leading, .trailing], 25)
        }
        .padding(.horizontal, 15)
        .padding(.top, 60)
        .padding(.bottom, isFocused ? 5 : 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .onAppear(){
            viewModel.checkExistUser()
        }
        .navigationTitle("EmailView")
    }
}

