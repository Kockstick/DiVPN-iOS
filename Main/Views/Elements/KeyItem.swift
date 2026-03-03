//
//  KeyItem.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 26.02.2026.
//

import SwiftUI

struct KeyItem: View {
    
    var index: Int
    var key: OutlineKey
    var isSelected: Bool
    
    var onTap: () -> Void
    var onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 10){
            RadioButton(isSelected: isSelected)
                .onTapGesture {
                    onSelect()
                }
            
            Text(index == 0 ? "My access key" : (key.name?.isEmpty == false ? key.name! : "Key \(key.id)"))
                .font(.body).bold()
                .foregroundStyle(key.id == "0" ? Color("TextSecondary") : Color("TextPrimary"))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    onTap()
                }
            
            Text(formatBytes(key.usedBytes))
                .font(.body).bold()
                .foregroundStyle(Color("TextSecondary"))
                .lineLimit(1)
                .onTapGesture {
                    onTap()
                }
        }
        .padding(.vertical, 10)
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(
            fromByteCount: bytes,
            countStyle: .binary
        )
    }
}
