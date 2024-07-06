import Foundation

extension GeoURI {
    /// Creates a new GeoURI from the provided `URL`.
    ///
    /// The URL must adhere to the [rfc5870](https://datatracker.ietf.org/doc/html/rfc5870) specification.
    public init(url: URL) throws(GeoURIParsingError) {
        do {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                throw GeoURIError.badURL
            }
            
            // scheme must be "geo"
            guard components.scheme?.caseInsensitiveCompare(Self.scheme) == .orderedSame else {
                throw GeoURIError.incorrectScheme
            }
            
            let pathComponents = components.path.components(separatedBy: ",")
            // path components must contain 2 or 3 doubles
            guard [2,3].contains(pathComponents.count), pathComponents.allSatisfy({ Double($0) != nil }) else {
                throw GeoURIError.badURL
            }
            
            guard let latitude = pathComponents.double(at: 0) else {
                throw GeoURIError.invalidLatitude
            }
            
            guard let longitude = pathComponents.double(at: 1) else {
                throw GeoURIError.invalidLongitude
            }
            
            let altitude = pathComponents.double(at: 2)
            
            // parse query items - unknown items will be ignored
            var uval: Double? = nil
            if let queryItems = components.queryItems {
                try Self.parseCoordinateReferenceSystem(fromQueryItems: queryItems)
                uval = try Self.parseUncertainty(fromQueryItems: queryItems)
            }
            
            try self.init(latitude: latitude, longitude: longitude, altitude: altitude, uncertainty: uval)
            
        } catch let err as GeoURIError {
            // wrap the error in a parsing error
            throw GeoURIParsingError(url: url, kind: err)
        } catch {
            throw GeoURIParsingError(url: url, kind: .badURL)
        }
    }
    
    /// A `URL` as defined by the [rfc5870](https://datatracker.ietf.org/doc/html/rfc5870#ref-ISO.6709.2008).
    public var url: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.path = [latitude, longitude, altitude]
            .compactMap { $0 }
            .compactMap { $0.formatted(GeoURI.numberStyle) }
            .joined(separator: ",")
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: ParameterName.crs.name, value: crs.rawValue)
        ]
        
        if let uncertainty {
            queryItems.append(
                URLQueryItem(
                    name: ParameterName.uncertainty.name,
                    value: uncertainty.formatted(GeoURI.numberStyle)
                )
            )
        }
        components.queryItems = queryItems

        return components.url
    }
    
    // MARK: - Private
    
    private enum ParameterName: String, CaseIterable {
        case crs
        case uncertainty = "u"
        
        var name: String { rawValue }
    }
    
    @discardableResult
    private static func parseCoordinateReferenceSystem(fromQueryItems queryItems: [URLQueryItem]) throws -> CoordinateReferenceSystem {
        let value = try value(forParameter: .crs, in: queryItems)
        guard let value else { return .wgs84 }
        
        guard let crs = CoordinateReferenceSystem(rawValue: value.lowercased()) else {
            throw GeoURIError.unsupportedCoordinateReferenceSystem(value)
        }
        
        return crs
    }
    
    private static func parseUncertainty(fromQueryItems queryItems: [URLQueryItem]) throws -> Double? {
        let value = try value(forParameter: .uncertainty, in: queryItems)
        guard let value else { return nil }
        
        guard let uncertainty = Double(value), uncertainty >= .zero else {
            throw GeoURIError.invalidUncertainty
        }
        
        return uncertainty
    }
    
    private static func value(forParameter parameter: ParameterName, in queryItems: [URLQueryItem]) throws(GeoURIError) -> String? {
        
        let items = queryItems.filter {
            $0.name.caseInsensitiveCompare(parameter.name) == .orderedSame
        }
        
        guard !items.isEmpty else { return nil }
        
        guard items.count <= 1 else {
            throw .duplicateQueryItem(name: parameter.name)
        }
        
        guard let value = items.first?.value else {
            throw .invalidQueryItem(name: parameter.name)
        }
        
        return value
    }
}

private extension Collection where Element == String {
    func double(at index: Index) -> Double? {
        guard indices.contains(index) else { return nil }
        return Double(self[index])
    }
}
