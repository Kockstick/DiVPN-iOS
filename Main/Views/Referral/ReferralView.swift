//
//  ReferralView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 14.09.2025.
//

import SwiftUI

struct ReferralView: View {
    let onSuccess: () -> Void
    
    @EnvironmentObject var referralModel: ReferralManager
    
    @StateObject private var viewModel = ReferralViewModel()
    @FocusState private var isFocused: Bool
    
    @State var code: String = ""
    @State var showError: Bool = false
    
    private let LOG_TAG = "ReferralView"
    private let logger = DiLogger.shared
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                    .frame(maxHeight: 30)
                
                Text("Do you have a referral code?")
                    .font(.title).bold()
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                ZStack{
                    TextField("", text: $code, prompt: Text("7YJPC5").foregroundColor(Color("TextSecondary")))
                        .frame(height: 55)
                        .padding(.horizontal, 16)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .textContentType(.oneTimeCode)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isFocused ? Color(!viewModel.loading ? "Active" : "Surface") : Color("Border"), lineWidth: 2)
                        )
                        .animation(.easeInOut(duration: 0.18), value: isFocused)
                        .foregroundColor(Color("TextPrimary"))
                        .font(.title3).bold()
                        .contentShape(Rectangle())
                        .multilineTextAlignment(.center)
                        .trackingIfAvailable(value: 3)
                        .onChange(of: code) { newValue in
                            showError = false
                            
                            if newValue.count == 0 {
                                logger.i("Input cleared", tag: LOG_TAG)
                            } else if newValue.count <= 6 {
                                logger.i("Input changed: \(newValue)", tag: LOG_TAG)
                            }
                            
                            if newValue.count > 6 {
                                let trimmed = String(newValue.prefix(6))
                                logger.w("Input longer than 6, trimming to \(trimmed)", tag: LOG_TAG)
                                code = trimmed
                            } else if newValue.count == 6 {
                                logger.i("Code complete, calling useReferral(\(newValue))", tag: LOG_TAG)
                                viewModel.useReferral(code: code){ result in
                                    if result {
                                        logger.i("useReferral success", tag: LOG_TAG)
                                        DispatchQueue.main.async{
                                            logger.i("onSuccess dispatched", tag: LOG_TAG)
                                            onSuccess()
                                        }
                                    }
                                    else{
                                        logger.w("useReferral failed, showing error", tag: LOG_TAG)
                                        showError = true
                                    }
                                }
                            }
                        }
                }
                .onTapGesture {
                    logger.i("TextField tapped, focusing", tag: LOG_TAG)
                    isFocused = true
                }
                
                HStack(spacing: 1){
                    Image("error")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("Error"))
                    Text("Invalid code or not found")
                        .font(.footnote).bold()
                }
                .opacity(showError ? 1 : 0)
                
                Spacer()
                
                DrawButton(title: "Skip", bgColor: Color("Surface"), textColor: Color("TextPrimary"), isLoading: false){
                    logger.i("Skip tapped", tag: LOG_TAG)
                    onSuccess()
                }
                
                Spacer()
                    .frame(maxHeight: 10)
                
                DrawButton(title: "What is it?", bgColor: Color("Accent"), textColor: Color("TextPrimaryFixed"), isLoading: false){
                    logger.i("What is it? tapped", tag: LOG_TAG)
                    referralModel.showReferralInviteInAuth = true
                }
            }
            .frame(alignment: .top)
            .padding([.leading, .trailing], 25)
        }
        .padding(.horizontal, 15)
        .padding(.top, 60)
        .padding(.bottom, isFocused ? 5 : 50)
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
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: showError)
        .navigationTitle("ReferralView")
    }
}
