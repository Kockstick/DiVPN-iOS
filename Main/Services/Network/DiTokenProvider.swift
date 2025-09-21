//
//  DiTokenProvider.swift
//  Outline
//
//  Created by Diesperov Konstantin on 21.09.2025.
//

struct DiTokenProvider: TokenProvider {
    var accessToken: String? {
        (DiStorage.loadToken() ?? "").unquoted.nilIfEmpty
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
