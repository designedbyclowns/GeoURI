import Foundation

/**
 An error parsing a GeoURI from a URL.
 */
public struct GeoURIParsingError: Error {
    /// The `URL` that could not be parsed.
    let url: URL
    /// The underlying ``GeoURIError``.
    let kind: GeoURIError
}

extension GeoURIParsingError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.url == rhs.url && lhs.kind == rhs.kind
    }
}
