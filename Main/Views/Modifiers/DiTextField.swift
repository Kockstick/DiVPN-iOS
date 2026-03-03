//
//  DiTextField.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 01.03.2026.
//

import SwiftUI

struct DiTextField: View {
    
    @Binding var text: String
    
    var prompt: String
    var textColor: Color
    var upnote: String
    var upnoteColor: Color
    var borderColor: Color?
    
    var externalFocus: FocusState<Bool>.Binding?
    @FocusState private var internalFocus: Bool
    
    var onChange: (_ value: String) -> Void
    
    init(
        text: Binding<String>,
        prompt: String = "",
        textColor: Color = Color("TextPrimary"),
        upnote: String = "",
        upnoteColor: Color = Color("TextPrimaryFixed"),
        borderColor: Color? = nil,
        isFocused: FocusState<Bool>.Binding? = nil,
        onChange: @escaping (_ value: String) -> Void
    ) {
        self._text = text
        self.prompt = prompt
        self.textColor = textColor
        self.upnote = upnote
        self.upnoteColor = upnoteColor
        self.borderColor = borderColor
        self.onChange = onChange
        
        externalFocus = isFocused
    }
    
    var body: some View {
        var isFocused = externalFocus ?? $internalFocus
        
        VStack {
            if upnote != "" {
                UpNote(
                    text: upnote,
                    textColor: upnoteColor,
                    borderColor: borderColor ?? (isFocused.wrappedValue ? Color("Active") : Color("TextSecondary")),
                    isFocused: isFocused.wrappedValue
                )
                .onTapGesture {
                    isFocused.wrappedValue = true
                }
            }
            
            TextField(
                "",
                text: $text,
                prompt: Text(prompt).foregroundColor(Color("TextSecondary"))
            )
            .frame(height: 55)
            .padding(.horizontal, 16)
            .cornerRadius(10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .focused(isFocused)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        borderColor ?? (isFocused.wrappedValue ? Color("Active") : Color("TextSecondary")),
                        lineWidth: 2
                    )
            )
            .animation(.easeInOut(duration: 0.18), value: isFocused.wrappedValue)
            .foregroundColor(textColor)
            .font(.title3).bold()
            .minimumScaleFactor(0.8)
            .contentShape(Rectangle())
            .onChange(of: text) { newValue in
                onChange(newValue)
            }
        }
    }
}
