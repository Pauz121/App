import Foundation

enum AccessCodeGenerator {
    private static let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")

    static func make(prefix: String = "PT", length: Int = 6, existingCodes: Set<String>) -> String {
        var code: String
        repeat {
            let token = String((0..<length).map { _ in alphabet.randomElement() ?? "X" })
            code = "\(prefix)-\(token)"
        } while existingCodes.contains(code)
        return code
    }
}
