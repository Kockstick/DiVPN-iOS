//
//  VerificationResult.swift
//  Outline
//
//  Created by Diesperov Konstantin on 28.08.2025.
//

import Foundation
import UniformTypeIdentifiers

struct BugReportForm {
    let text: String
    let fileURL: URL
    
    func buildMultipartBody(boundary: String) throws -> Data {
        var body = Data()

        func append(_ string: String) {
            body.append(string.data(using: .utf8)!)
        }

        // text поле
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"Text\"\r\n\r\n")
        append("\(text)\r\n")

        // file поле
        let filename = fileURL.lastPathComponent
        let ext = fileURL.pathExtension.lowercased()
        let mime: String = {
            switch ext {
            case "log", "txt": return "text/plain"
            case "zip": return "application/zip"
            default: return "application/octet-stream"
            }
        }()

        let fileData = try Data(contentsOf: fileURL)

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"File\"; filename=\"\(filename)\"\r\n")
        append("Content-Type: \(mime)\r\n\r\n")
        body.append(fileData)
        append("\r\n")

        // завершение
        append("--\(boundary)--\r\n")

        return body
    }
}
