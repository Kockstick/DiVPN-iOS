//
//  FileManager+documentDirectory.swift
//  DiVPN
//
//  Created by admin on 08.05.2026.
//

import Foundation

extension FileManager {
    var documentDirectory: URL {
        guard let url = urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not locate document directory")
        }

        return url
    }
}
