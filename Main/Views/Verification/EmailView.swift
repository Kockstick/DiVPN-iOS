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
    
    private let exampleEmail: String = "example@gmail.com"
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Image("MailIcon")
                        .resizable()
                        .frame(width: 80, height: 100)
                        .foregroundColor(Color("TextPrimary"))
                    Image("Mail")
                        .resizable()
                        .frame(width: 130, height: 100)
                        .foregroundColor(Color("TextPrimary"))
                }
                Spacer()
                ZStack{
                    TextField("", text: $viewModel.email, prompt: Text(exampleEmail).foregroundColor(Color("TextSecondary")))
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
                                .stroke(isFocused ? Color("Active") : Color("TextSecondary"), lineWidth: 2)
                        )
                        .animation(.easeInOut(duration: 0.18), value: isFocused)
                        .foregroundColor(Color("TextPrimary"))
                        .font(.title3).bold()
                        .minimumScaleFactor(0.8)
                        .contentShape(Rectangle())
                        .opacity(viewModel.loading ? 0.5 : 2)
                        .onChange(of: viewModel.email) { newValue in
                            if viewModel.isIncorrectEmail {
                                let isValidEmail: Bool = viewModel.validateEmail(newValue)
                                if isValidEmail {
                                    viewModel.isIncorrectEmail = false
                                }
                            }
                            
                            isValid = newValue.contains("@") && newValue.contains(".")
                            viewModel.loading = false
                        }
                }
                .onTapGesture {
                    isFocused = true
                }
                HStack(spacing: 2){
                    if(viewModel.isIncorrectEmail){
                        Image("error")
                            .frame(alignment: .center)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color("Error"))
                    }
                    Text(viewModel.isIncorrectEmail ? "Incorrect email format" : "If you don’t have an account, we’ll create one for you")
                        .frame(maxWidth: viewModel.isIncorrectEmail ? nil : .infinity, alignment: viewModel.isIncorrectEmail ? .center : .leading)
                        .font(.footnote)
                }
                .padding(.horizontal, 15)
                .shimmer(viewModel.loading)
                
                Spacer()
                
                HStack{
                    Toggle(isOn: $agreementManager.isPrivacyPolicyAccept) {
                        EmptyView()
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .frame(width: 35, height: 35)
                    .disabled(viewModel.loading)
                    
                    Text(attributedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote).bold()
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.leading)
                        .onTapGesture {
                            if attributedText.range(of: NSLocalizedString("privacy_policy", comment: "")) != nil {
                                showPrivacyPolicy = true
                            }
                        }
                        .sheet(isPresented: $showPrivacyPolicy) {
                            SafariView(url: URL(string: Bundle.main.privacyPolicyUrl)!)
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                    .frame(maxHeight: 15)
                
                DrawButton(title: "Continue", bgColor: Color(!viewModel.loading && agreementManager.isPrivacyPolicyAccept ? !viewModel.isIncorrectEmail ? "Accent" : "Error" : "Surface"), textColor: Color("TextPrimaryFixed"), isLoading: viewModel.loading){
                    viewModel.onButtonClick(){ success in
                        if success {
                            onNext()
                        }
                    }
                }
                .opacity(colorScheme == .dark ? 1 : viewModel.loading ? 0.3 : isValid ? 1 : 0.3)
                .disabled(viewModel.loading || !isValid || viewModel.isIncorrectEmail || !agreementManager.isPrivacyPolicyAccept)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            }
            .frame(alignment: .top)
            .padding([.leading, .trailing], 25)
        }
        .padding(.horizontal, 15)
        .padding(.top, 60)
        .padding(.bottom, isFocused ? 5 : 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .onAppear(){
            viewModel.checkExistUser()
        }
        .navigationTitle("EmailView")
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

private var attributedText: AttributedString {
    var result = AttributedString(NSLocalizedString("agree_privacy_policy", comment: ""))
    if let range = result.range(of: NSLocalizedString("privacy_policy", comment: "")) {
        result[range].foregroundColor = .blue
        result[range].underlineStyle = .single
    }
    return result
}
