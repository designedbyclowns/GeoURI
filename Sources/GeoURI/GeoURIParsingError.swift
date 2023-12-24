import Foundation

/**
 Indicates an error parsing a GeoURI from a URL.
 */
public struct GeoURIParsingError: Error {
    /// The `URL` that could not be parsed.
    public let url: URL
    /// The underlying ``GeoURIError``.
    public let kind: GeoURIError
}

extension GeoURIParsingError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.url == rhs.url && lhs.kind == rhs.kind
    }
}

extension GeoURIParsingError: LocalizedError {
    public var errorDescription: String? {
        let description = "An error occurred parsing the URL '\(url.absoluteString)'"
        
        guard let errorDescription = kind.errorDescription, !errorDescription.isEmpty else {
            return description + "."
        }

        return "\(description): \(errorDescription)"
    }
    
    public var failureReason: String? {
        kind.failureReason
    }
    
    public var recoverySuggestion: String? {
        kind.recoverySuggestion
    }
}
