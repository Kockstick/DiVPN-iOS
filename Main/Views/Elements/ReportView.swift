//
//  ReportView.swift
//  Outline
//
//  Created by Diesperov Konstantin on 24.08.2025.
//

import SwiftUI

struct ReportView: View{
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @Binding var bugReportSent: Bool
    
    @StateObject private var viewModel = ReportViewModel()
    
    @FocusState private var isFocused: Bool
    
    private let LOG_TAG: String = "ReportView"
    private let logger = DiLogger.shared
    
    var body: some View{
        ZStack{
            VStack{
                Spacer()
                    .frame(maxHeight: 10)
                
                Text("Bug report")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity)
                
                Spacer()
                    .frame(maxHeight: 10)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
                    .foregroundColor(Color("TextSecondary"))
                
                Spacer()
                    .frame(maxHeight: 10)
                
                ZStack(alignment: .topLeading) {
                    if viewModel.text.isEmpty {
                        Text("Describe in detail the error you encountered here.")
                            .foregroundColor(Color("TextSecondary"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 17)
                    }
                    
                    DiTextEditor(text: $viewModel.text)
                        .focused($isFocused)
                        .padding(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(Color("Surface"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color("Active") : Color("Border"), lineWidth: 2)
                )
                
                Spacer()
                    .frame(maxHeight: 10)
                
                HStack{
                    Image("file")
                        .font(.system(size: 80, weight: .thin))
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("TextPrimary"))
                    VStack{
                        Text("Log file")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("TextPrimary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("A log file will be attached to the message to help diagnose the issue more effectively.")
                            .font(.system(size: 16))
                            .foregroundColor(Color("TextSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                    .frame(maxHeight: 30)
                
                Button(action: {
                    Task{
                        await viewModel.sendBugReport()
                    }
                    logger.i("Send tapped; textLength=\(viewModel.text.count)", tag: LOG_TAG)
                    isFocused = false
                    DispatchQueue.main.async {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        bugReportSent = true
                        dismiss()
                    }
                }) {
                    Text("Send")
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
                    RoundedRectangle(cornerRadius: 12).stroke(Color("Border"), lineWidth: 2)
                )
                .disabled(viewModel.text.isEmpty)
                .opacity(viewModel.text.isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
        }
        .background((Color("Background")))
        .overlay(alignment: .topLeading) {
            Button(action: {
                isFocused = false
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
                    Text("options")
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextPrimary"))
                }
            }
            .padding(.top, 10)
            .padding(.leading, 10)
            .accessibilityLabel("Close")
        }
        .onDisappear {
            isFocused = false
        }
    }
}
