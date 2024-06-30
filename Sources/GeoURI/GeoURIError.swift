import Foundation

public enum GeoURIError: Error, Equatable {
    case malformed
    case badURL
    case incorrectScheme
    case invalidLatitude
    case invalidLongitude
    case unsupportedCoordinateReferenceSystem(String)
    case invalidUncertainty
    case duplicateQueryItem(name: String)
    case invalidQueryItem(name: String)
}

extension GeoURIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .malformed:
            return "Syntax is invalid."
        case .badURL:
            return "The URL is not a valid GeoURI."
        case .duplicateQueryItem(let name):
            return "The '\(name)' query item was specified more than once."
        case .incorrectScheme:
            return "The URL scheme must be 'geo'."
        case .invalidLatitude:
            return "The latitude is invalid."
        case .invalidLongitude:
            return "The longitude is invalid."
        case .invalidQueryItem(let name):
            return "The '\(name)' query item is invalid."
        case .invalidUncertainty:
            return "The uncertainty is invalid."
        case .unsupportedCoordinateReferenceSystem(let value):
            return "The '\(value)' coordinate reference system is not supported."
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .malformed, .badURL, .incorrectScheme, .invalidQueryItem(_):
            return errorDescription
        case .invalidLatitude:
            return "Latitude values range from -90 to 90."
        case .invalidLongitude:
            return "Longitude values range from -180 to 180."
        case .unsupportedCoordinateReferenceSystem(_):
            return "WGS-84 (wgs84) is the only supported coordinate reference system."
        case .invalidUncertainty:
            return "Uncertainty must be greater than or equal to zero, or nil."
        case .duplicateQueryItem(let name):
            return "The '\(name)' must only be provided once."
        }
    }
    
    public var recoverySuggestion: String? {
        "Review the GeoURI specification: (https://datatracker.ietf.org/doc/html/rfc5870#ref-ISO.6709.2008)."
    }
}

extension GeoURIError: CustomNSError {
    public static let errorDomain = "com.desigendbyclowns.GeoURI"
}
