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
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                
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
                        .font(.system(size: 20, weight: .bold))
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
                        .font(.system(size: 12))
                }
                .opacity(showError ? 1 : 0)
                
                Spacer()
                
                Button(action: {
                    logger.i("Skip tapped", tag: LOG_TAG)
                    onSuccess()
                }) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, maxHeight: 55)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("Surface"))
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("Border"), lineWidth: 2)
                )
                .compositingGroup()
                
                Spacer()
                    .frame(maxHeight: 10)
                
                Button(action: {
                    logger.i("What is it? tapped", tag: LOG_TAG)
                    referralModel.showReferralInviteInAuth = true
                }) {
                    Text("What is it?")
                        .font(.system(size: 16, weight: .bold))
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
            .frame(alignment: .top)
            .padding([.leading, .trailing], 25)
        }
        .padding(.horizontal, 15)
        .padding(.top, 60)
        .padding(.bottom, isFocused ? 5 : 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("Background"))
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: showError)
        .navigationTitle("ReferralView")
    }
}
