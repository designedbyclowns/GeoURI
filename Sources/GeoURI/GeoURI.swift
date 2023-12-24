import Foundation
/**
 A type that represents a URI for geographic locations using the 'geo' scheme name.
 
 The scheme provides the textual representation of the location's spatial coordinates
 in either two or three dimensions (latitude, longitude, and optionally altitude
 for the default CRS of WGS-84).
 
 An example of such a 'geo' URI follows:

 ```
 geo:13.4125,103.8667
 ```
 
 > Tip: The GeoURI (rfc5870) specification can be viewed [here](https://datatracker.ietf.org/doc/html/rfc5870).
 */
public struct GeoURI {

    public enum CoordinateReferenceSystem: String {
        /// The [World Geodetic System 1984](https://earth-info.nga.mil/?dir=wgs84&action=wgs84) (WGS-84).
        case wgs84
    }
    
    /// The latitude of the identified location in decimal degrees in the reference system WGS-84.
    ///
    /// Latitudes in the Southern hemispheres are signed negative with a leading dash.
    ///
    /// Latitude values range from -90 to 90.
    public let latitude: Double
    
    /// The longitude of the identified location in decimal degrees in the reference system WGS-84.
    ///
    /// Longitude values in the Western hemispheres are signed negative with a leading dash.
    ///
    /// Longitude values range from -180 to 180.
    ///
    /// - Note: The longitude of coordinate values reflecting the poles (``latitude`` values of -90 or 90 degrees) will be set to 0.
    public let longitude: Double
    
    /// The altitude of the identified location in meters in the reference system WGS-84.
    ///
    /// A `nil` value _may_ be assumed to refer to the respective location on Earth's
    /// physical surface at the given latitude and longitude.
    ///
    /// Values below the WGS-84 reference geoid (depths) are signed negative with
    ///  a leading dash.
    ///
    /// - Warning: An altitude value of zero _must not_ be mistaken to refer to "ground elevation".
    public private(set) var altitude: Double?
    
    /// The Coordinate Reference System (CRS) used to interpret coordinate values.
    ///
    /// Currently the only supported CRS is the [World Geodetic System 1984](https://earth-info.nga.mil/?dir=wgs84&action=wgs84) (WGS-84).
    ///
    /// - Note: See [rfc5870#section-3.4.1](https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.1).
    public private(set) var crs: CoordinateReferenceSystem = .wgs84
    
    /// Indicates the amount of uncertainty in the location as a value in meters.
    ///
    /// A `nil` value indicates that the uncertainty is unknown.
    ///
    /// If the intent is to indicate a specific point in space, the value _may_ be set to zero. The value applies to all dimensions of the location.
    ///
    /// - Tip: Zero uncertainty and absent uncertainty are never the same thing.
    /// See [rfc5870#section-3.4.3](https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.3).
    ///
    /// - Warning: The number of digits of the values in ``latitude``, ``longitude``, and ``altitude`` _must not_ be interpreted as an indication to the level of uncertainty.
    public private(set) var uncertainty: Double?
    
    /// Creates a new GeoURI.
    /// - Parameters:
    ///   - latitude: The ``latitude`` of the identified location in decimal degrees in the reference system WGS-84.
    ///   - longitude: The ``longitude`` of the identified location in decimal degrees in the reference system WGS-84.
    ///   - altitude: The ``altitude`` of the identified location in meters in the reference system WGS-84.
    ///   - uncertainty: The amount of ``uncertainty`` in the location as a value in meters.
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
    
    /// Creates a new GeoURI from the provided `URL`.
    ///
    /// The URL must adhere to the [rfc5870](https://datatracker.ietf.org/doc/html/rfc5870) specification.
    public init(url: URL) throws {
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
            
            try self.init(latitude: latitude, longitude: longitude, altitude: altitude)
            
            // parse query items - unknown items will be igored
            if let queryItems = components.queryItems {
                self.crs = try parseCoordinateReferenceSystem(fromQueryItems: queryItems)
                self.uncertainty = try parseUncertainty(fromQueryItems: queryItems)
            }
            
        } catch let err as GeoURIError {
            // wrap the error in a parsing error
            throw GeoURIParsingError(url: url, kind: err)
        } catch {
            throw GeoURIParsingError(url: url, kind: .badURL)
        }
    }
    
    /// The altitude represented as a `Measurement` type.
    public var altitudeMeasurement: Measurement<UnitLength>? {
        altitude.flatMap { Measurement<UnitLength>(value: $0, unit: .meters) }
    }
    
    /// A `URL` as defined by the [rfc5870](https://datatracker.ietf.org/doc/html/rfc5870#ref-ISO.6709.2008).
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

private extension Collection where Element == String {
    func double(at index: Index) -> Double? {
        guard indices.contains(index) else { return nil }
        return Double(self[index])
    }
}
