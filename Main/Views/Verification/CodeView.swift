//
//  CodeView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 11.08.2025.
//

import SwiftUI

struct CodeView: View {
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel = CodeViewModel()
    
    @State var code: String = ""
    @FocusState private var isFocused: Bool
    
    private let LOG_TAG: String = "CodeView"
    private let logger = DiLogger.shared
    
    var body: some View {
        ZStack{
            VStack{
                DiHeader(title: "Sign in", subtitle: "Code", isAnimated: viewModel.loading)
                    .frame(alignment: .top)
                Spacer()
                ZStack{
                    TextField("", text: $code, prompt: Text("• • • • • •").foregroundColor(Color("TextSecondary")))
                        .frame(height: 55)
                        .padding(.horizontal, 16)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .textContentType(.oneTimeCode)
                        .keyboardType(.numberPad)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isFocused ? Color(!viewModel.loading ? "Active" : "Surface") : Color("Border"), lineWidth: 2)
                        )
                        .animation(.easeInOut(duration: 0.18), value: isFocused)
                        .foregroundColor(Color("TextPrimary"))
                        .font(.title3).bold()
                        .minimumScaleFactor(0.8)
                        .contentShape(Rectangle())
                        .multilineTextAlignment(.center)
                        .trackingIfAvailable(value: 3)
                        .onChange(of: code) { newValue in
                            logger.i("Code input changed; length=\(newValue.count)", tag: LOG_TAG)
                            if newValue.count > 6 {
                                code = String(newValue.prefix(6))
                                logger.w("Code trimmed to 6 chars", tag: LOG_TAG)
                            } else if newValue.count == 6 {
                                logger.i("Attempting verification (6 digits entered)", tag: LOG_TAG)
                                viewModel.verificate(code: code){ result in
                                    logger.i("Verification finished: \(result)", tag: LOG_TAG)
                                    if result {
                                        logger.i("Preload shadowsocks server", tag: LOG_TAG)
                                        ShadowsocksManager.shared.preloadKey()
                                        onSuccess()
                                    }
                                }
                            }
                        }
                }
                .onTapGesture {
                    isFocused = true
                    logger.i("TextField focused by tap", tag: LOG_TAG)
                }
                
                HStack(spacing: 1){
                    if(viewModel.verifErrorText != nil){
                        Image("error")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color("Error"))
                    }
                    
                    Text(viewModel.verifErrorText ?? NSLocalizedString("code_valid", comment: ""))
                        .font(.footnote)
                        .shimmer(viewModel.loading)
                }
                
                Spacer()
                
                Text(viewModel.timeToNewCode == 0 && !viewModel.loadingTimeToNewCode ? "You can request a new code now" : "Resend available in \(viewModel.timeToNewCodeText)  seconds")
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
                    .shimmer(viewModel.loadingTimeToNewCode || viewModel.loading)
                
                Button(action: {
                    logger.i("Send new code tapped", tag: LOG_TAG)
                    code = ""
                    viewModel.onButtonClick()
                }) {
                    HStack(spacing: 2){
                        Text("Send new code")
                            .font(.body).bold()
                            .foregroundColor(Color(colorScheme == .light ? "TextPrimaryFixed" : viewModel.loading || viewModel.timeToNewCode != 0 ? "TextSecondary" : "TextPrimaryFixed"))
                        Image("update")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(colorScheme == .light ? "TextPrimaryFixed" : viewModel.loading || viewModel.timeToNewCode != 0 ? "TextSecondary" : "TextPrimaryFixed"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .disabled(viewModel.timeToNewCode != 0)
                    .background(
                        Color(viewModel.timeToNewCode != 0 ? "Surface" : "Accent")
                            .cornerRadius(12)
                            .shadow(  // Переносим тень в background
                                color: .black.opacity(viewModel.loading || viewModel.timeToNewCode != 0 ? 0 : 0.15),
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
                .disabled(viewModel.timeToNewCode != 0)
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
        .navigationTitle("CodeView")
        .onAppear(){
            viewModel.getTimeToRequareNewCode()
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                isFocused = false
                dismiss()
            }) {
                HStack (spacing: 0){
                    Image(systemName: "chevron.left")
                        .font(.body).bold()
                        .foregroundColor(Color("TextPrimary"))
                        .frame(width: 16, height: 16)
                        .contentShape(Circle())
                    Text("email")
                        .font(.body)
                        .foregroundColor(Color("TextPrimary"))
                }
            }
            .padding(.top, 10)
            .padding(.leading, 10)
            .accessibilityLabel("Close")
            .onChange(of: viewModel.loading) { newValue in
                logger.i("loading changed: \(newValue)", tag: LOG_TAG)
            }
            .onChange(of: viewModel.loadingTimeToNewCode) { newValue in
                logger.i("loadingTimeToNewCode changed: \(newValue)", tag: LOG_TAG)
            }
            .onChange(of: viewModel.verifErrorText) { newValue in
                logger.i("verifErrorText changed: \(newValue ?? "nil")", tag: LOG_TAG)
            }
        }
    }
}
