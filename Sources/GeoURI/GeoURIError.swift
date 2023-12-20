public enum GeoURIError: Error, Equatable {
    case badURL
    case incorrectScheme
    case invalidLatitude
    case invalidLongitude
    case unsupportedCoordinateReferenceSystem(String)
    case invalidUncertainty
    case duplicateQueryItem(name: String)
    case invalidQueryItem(name: String)
}

