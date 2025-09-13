//
//  DiLogger.swift
//  Outline
//
//  Created by Diesperov Konstantin on 29.08.2025.
//

import Foundation
import UIKit

public enum DiLogLevel: String { case debug = "DEBUG", info = "INFO", warn = "WARN", error = "ERROR" }

public class DiLogger {
    public static let shared = DiLogger()
    
    private let queue = DispatchQueue(label: "DiLogger.queue", qos: .utility)
    private let maxBytes = 2 * 1024 * 1024        // 2 MB лимит
    private let keepBytes = 1_600_000             // сколько оставляем при обрезке (~1.6 MB)
    private let df: ISO8601DateFormatter
    private let fileURL: URL
    
    private init() {
        df = ISO8601DateFormatter()
        df.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let groupId = "group.Kockstik.DiVPN"
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)!
        let logsDir = container.appendingPathComponent("Logs", isDirectory: true)
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
        fileURL = logsDir.appendingPathComponent("divpn.log")

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
        
        logAppInfo()
    }
    
    public func log(_ level: DiLogLevel,
                    tag: String = "app",
                    _ message: @autoclosure () -> String,
                    file: StaticString = #file,
                    function: StaticString = #function,
                    line: UInt = #line) {
        let ts = df.string(from: Date())
        let shortFile = "\(file)".split(separator: "/").last ?? Substring("")
        //let lineStr = "\(ts) [\(level.rawValue)] [\(tag)] \(shortFile):\(line) \(function) — \(message())\n"
        let lineStr = "\(ts) [\(level.rawValue)] [\(tag)] — \(message())\n"
        print(lineStr)

        queue.async { [weak self] in
            guard let self = self, let data = lineStr.data(using: .utf8) else { return }
            self.append(data)
        }
    }
    
    private func logAppInfo() {
        let info = Bundle.main.infoDictionary
        let appVer = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        let iosVer = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        let deviceName = UIDevice.current.name

        let meta = """
        \n-----------------------------
        App launch info
        -----------------------------
        App version: \(appVer) (\(build))
        iOS version: \(iosVer)
        Device model: \(model)
        Device name: \(deviceName)
        Timestamp: \(Date())
        -----------------------------
        """

        log(.info, tag: "startup", meta)
    }
    
    public func snapshotURL() -> URL? {
        var url: URL?
        queue.sync {
            let tmp = fileURL.deletingLastPathComponent().appendingPathComponent("divpn-\(Int(Date().timeIntervalSince1970)).log")
            do { try FileManager.default.copyItem(at: fileURL, to: tmp); url = tmp } catch { }
        }
        return url
    }
    
    private func append(_ data: Data) {
        guard let handle = try? FileHandle(forWritingTo: fileURL) else { return }
        defer { try? handle.close() }
        do {
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
        } catch {
            return
        }
        capIfNeeded()
    }
    
    private func capIfNeeded() {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let sizeNum = attrs[.size] as? NSNumber else { return }
        let size = sizeNum.intValue
        guard size > maxBytes else { return }

        // Оставляем последние keepBytes, остальное выбрасываем
        let keep = min(keepBytes, size)
        let offset = UInt64(size - keep)

        do {
            // Читаем «хвост»
            guard let r = try? FileHandle(forReadingFrom: fileURL) else { return }
            try r.seek(toOffset: offset)
            let tail = try r.readToEnd() ?? Data()
            try r.close()

            // Перезаписываем файл только этим «хвостом»
            try tail.write(to: fileURL, options: .atomic)
        } catch {
            // если вдруг не получилось — ну, не судьба, переживем
        }
    }
    
    public func d(_ msg: @autoclosure () -> String, tag: String = "app") { log(.debug, tag: tag, msg()) }
    public func i(_ msg: @autoclosure () -> String, tag: String = "app") { log(.info, tag: tag, msg()) }
    public func w(_ msg: @autoclosure () -> String, tag: String = "app") { log(.warn, tag: tag, msg()) }
    public func e(_ msg: @autoclosure () -> String, tag: String = "app") { log(.error, tag: tag, msg()) }
}
