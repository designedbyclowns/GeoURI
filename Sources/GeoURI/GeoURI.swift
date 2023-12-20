import Foundation
/**
 https://datatracker.ietf.org/doc/html/rfc5870#ref-ISO.6709.2008
 */
public struct GeoURI {

    public enum CoordinateReferenceSystem: String {
        case wgs84
    }
    
    public let latitude: Double
    public let longitude: Double
    public private(set) var altitude: Double?
    public private(set) var crs: CoordinateReferenceSystem = .wgs84
    public private(set) var uncertainty: Double?
    
    public init(latitude: Double, longitude: Double, altitude: Double? = nil, uncertainty: Double? = nil) throws {
        guard (-90...90).contains(latitude) else {
            throw GeoURIError.invalidLatitude
        }
        self.latitude = latitude
        
        guard (-180.0...180.0).contains(longitude) else {
            throw GeoURIError.invalidLongitude
        }
        
        // normalize the longitude
        if latitude == -90.0 || latitude == 90.0 {
            // longitude is 0.0 at the poles
            self.longitude = .zero
        } else {
            // date line case
            self.longitude = longitude == -180.0 ? 180.0 : longitude
        }
        
        self.altitude = altitude
        
        if let uncertainty {
            guard uncertainty >= 0 else {
                throw GeoURIError.invalidUncertainty
            }
        }
        self.uncertainty = uncertainty
    }
    
    public init(url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw GeoURIParsingError(url: url, kind: .badURL)
        }
        
        guard components.scheme?.caseInsensitiveCompare(Self.scheme) == .orderedSame else {
            throw GeoURIParsingError(url: url, kind: .incorrectScheme)
        }
        
        let pathComponents = components.path.components(separatedBy: ",")
        guard pathComponents.allSatisfy({
            Double($0) != nil
        }) else {
            throw GeoURIParsingError(url: url, kind: .badURL)
        }
        
        let coordinateComponents = pathComponents.compactMap { Double($0) }
        
        guard [2,3].contains(coordinateComponents.count) else {
            throw GeoURIParsingError(url: url, kind: .badURL)
        }
        
        do {
            try self.init(
                latitude: coordinateComponents[0],
                longitude: coordinateComponents[1],
                altitude: coordinateComponents.indices.contains(2) ? coordinateComponents[2] : nil
            )
            
            if let queryItems = components.queryItems {
                self.crs = try parseCoordinateReferenceSystem(fromQueryItems: queryItems)
                self.uncertainty = try parseUncertainty(fromQueryItems: queryItems)
            }
            
        } catch let err as GeoURIError {
            throw GeoURIParsingError(url: url, kind: err)
        } catch {
            throw GeoURIParsingError(url: url, kind: .badURL)
        }
    }
    
    public var altitudeMeasurement: Measurement<UnitLength>? {
        altitude.flatMap { Measurement<UnitLength>(value: $0, unit: .meters) }
    }
    
    public var url: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.path = [latitude, longitude, altitude]
            .compactMap { $0 }
            .compactMap { Self.numberFormatter.string(from: NSNumber(value: $0)) }
            .joined(separator: ",")
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: ParameterName.crs.name, value: crs.rawValue)
        ]
        
        if let uncertainty {
            queryItems.append(
                URLQueryItem(
                    name: ParameterName.uncertainty.name,
                    value: Self.numberFormatter.string(from: NSNumber(value: uncertainty))
                )
            )
        }
        components.queryItems = queryItems

        return components.url
    }
    
    // MARK: - Internal
    
    static let scheme = "geo"
    
    static var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        return formatter
    }()
    
    // MARK: - Private
    
    private enum ParameterName: String, CaseIterable {
        case crs
        case uncertainty = "u"
        
        var name: String { rawValue }
    }
    
    private func parseCoordinateReferenceSystem(fromQueryItems queryItems: [URLQueryItem]) throws -> CoordinateReferenceSystem {
        let value = try value(forParameter: .crs, in: queryItems)
        guard let value else { return .wgs84 }
        
        guard let crs = CoordinateReferenceSystem(rawValue: value.lowercased()) else {
            throw GeoURIError.unsupportedCoordinateReferenceSystem(value)
        }
        
        return crs
    }
    
    private func parseUncertainty(fromQueryItems queryItems: [URLQueryItem]) throws -> Double? {
        let value = try value(forParameter: .uncertainty, in: queryItems)
        guard let value else { return nil }
        
        guard let uncertainty = Double(value), uncertainty >= .zero else {
            throw GeoURIError.invalidUncertainty
        }
        
        return uncertainty
    }
    
    private func value(forParameter parameter: ParameterName, in queryItems: [URLQueryItem]) throws -> String? {
        
        let items = queryItems.filter {
            $0.name.caseInsensitiveCompare(parameter.name) == .orderedSame
        }
        
        guard !items.isEmpty else { return nil }
        
        guard items.count <= 1 else {
            throw GeoURIError.duplicateQueryItem(name: parameter.name)
        }
        
        guard let value = items.first?.value else {
            throw GeoURIError.invalidQueryItem(name: parameter.name)
        }
        
        return value
    }
    
    
}

