//
//  PromocodeViewModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 11.10.2025.
//

import SwiftUI

class PromocodeViewModel: ObservableObject{
    @Published var loading: Bool = false
    
    private let LOG_TAG: String = "PromocodeViewModel"
    private let logger = DiLogger.shared
    
}
