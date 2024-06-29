import Foundation
import RegexBuilder

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
public struct GeoURI: Sendable {

    public enum CoordinateReferenceSystem: String, Sendable {
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
    public let altitude: Double?
    
    /// The Coordinate Reference System (CRS) used to interpret coordinate values.
    ///
    /// Currently the only supported CRS is the [World Geodetic System 1984](https://earth-info.nga.mil/?dir=wgs84&action=wgs84) (WGS-84).
    ///
    /// - Note: See [rfc5870#section-3.4.1](https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.1).
    public let crs: CoordinateReferenceSystem = .wgs84
    
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
    public let uncertainty: Double?
    
    /// Creates a new GeoURI.
    /// - Parameters:
    ///   - latitude: The ``latitude`` of the identified location in decimal degrees in the reference system WGS-84.
    ///   - longitude: The ``longitude`` of the identified location in decimal degrees in the reference system WGS-84.
    ///   - altitude: The ``altitude`` of the identified location in meters in the reference system WGS-84.
    ///   - uncertainty: The amount of ``uncertainty`` in the location as a value in meters.
    public init(latitude: Double, longitude: Double, altitude: Double? = nil, uncertainty: Double? = nil) throws {
        guard (-90.0...90.0).contains(latitude) else {
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
    
    /// Creates a new GeoURI from the provided `String`.
    ///
    /// The string must adhere to the [rfc5870](https://datatracker.ietf.org/doc/html/rfc5870) specification.
    public init(string: String) throws {
        
        let stringValue = string.lowercased()
                
        guard stringValue.unicodeScalars.allSatisfy({ Self.allowedCharacters.contains($0) }) else {
            throw GeoURIError.malformed
        }
        
        guard !stringValue.hasSuffix(","), !stringValue.hasSuffix("=") else {
            throw GeoURIError.malformed
        }
        
        guard let match = stringValue.lowercased().firstMatch(of: Self.regex) else {
            throw GeoURIError.malformed
        }
        
        if let crs = match.4 {
            guard let _ = CoordinateReferenceSystem(rawValue: String(crs)) else {
                throw GeoURIError.unsupportedCoordinateReferenceSystem(String(crs))
            }
        }
        
        try self.init(latitude: match.1, longitude: match.2, altitude: match.3, uncertainty: match.5)
    }
    
    /// The altitude represented as a `Measurement` type.
    public var altitudeMeasurement: Measurement<UnitLength>? {
        altitude.flatMap { Measurement<UnitLength>(value: $0, unit: .meters) }
    }
    
    // MARK: - Internal
    
    static let scheme = "geo"
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 0
        // 8 decimal places represents 1.1132 mm at the equator.
        formatter.maximumFractionDigits = 8
        formatter.decimalSeparator = "."
        formatter.positivePrefix = ""
        formatter.negativePrefix = "-"
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    // MARK: - Private
    
    nonisolated(unsafe) private static let regex = Regex {
        Anchor.startOfLine
        "geo:"
        Capture {
            One(.localizedDouble(locale: .current)) // 1 latitude
        }
        ","
        Capture {
            One(.localizedDouble(locale: .current)) // 2 longitude
        }
        Optionally {
            ","
            Capture {
                One(.localizedDouble(locale: .current)) // 3 altitude
            }
        }
        Optionally {
            ";crs="
            Capture {
                OneOrMore(.word) // 4 crs
            }
        }
        Optionally {
            ";u="
            Capture {
                One(.localizedDouble(locale: .current)) // 5 uncertainty
            }
        }
    }
    
    private static let allowedCharacters = {
        var allowed = CharacterSet()
        allowed.formUnion(.lowercaseLetters)
        allowed.formUnion(.decimalDigits)
        allowed.insert(charactersIn: ":-,.;=")
        return allowed
    }()
}

