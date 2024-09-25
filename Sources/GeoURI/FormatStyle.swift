import Foundation

public extension GeoURI {
    /// A `FormatStyle` that converts a ``GeoURI`` into a string
    ///  representation.
    ///
    ///Usage:
    ///
    ///  ```swift
    ///  let geoURI = try! GeoURI(latitude: 48.2010, longitude: 16.3695)
    ///  let short = geoURI.formatted(.short) // "geo:48.201,16.3695"
    ///  let full = geoURI.formatted(.full)   // "geo:48.201,16.3695;crs=wgs84"
    ///  ```
    struct FormatStyle: Foundation.FormatStyle {
        /// Include the Coordinate Reference System (CRS) in the formatted output.
        public var includeCRS: Bool
        
        public init(includeCRS: Bool = false) {
            self.includeCRS = includeCRS
        }
        
        // MARK: Customization Method Chaining

        public func includeCRS(_ includeCRS: Bool) -> Self {
            .init(includeCRS: includeCRS)
        }
        
        // MARK: FormatStyle
        
        /// The type this format style accepts as input.
        public typealias FormatInput = GeoURI
        /// The type this format style produces as output.
        public typealias FormatOutput = String
        
        /// Formats a ``GeoURI`` value, using this style.
        public func format(_ value: GeoURI) -> String {
            let path = [value.latitude, value.longitude, value.altitude]
                .compactMap { $0 }
                .compactMap { $0.formatted(GeoURI.numberStyle) }
                .joined(separator: ",")
            
            var str = "geo:\(path)"
            
            if includeCRS {
                str.append(";crs=\(value.crs)")
            }
            
            if let uncertainty = value.uncertainty {
                str.append(";u=\(uncertainty.formatted(GeoURI.numberStyle))")
            }
            
            return str
        }
    }
}

extension FormatStyle where Self == GeoURI.FormatStyle {
    public static var full:  GeoURI.FormatStyle { .init(includeCRS: true) }
    public static var short:  GeoURI.FormatStyle { .init(includeCRS: false) }
}

extension GeoURI {
    /// Converts `self` to its textual representation.
    /// - Returns: String
    public func formatted(includeCRS: Bool = false) -> String {
        Self.FormatStyle(includeCRS: includeCRS).format(self)
    }
    
    /// Converts `self` to a string representation.
    /// - Parameter style: The format for formatting `self`
    /// - Returns: A string representations of `self` using the given `style`.
    public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == GeoURI {
        style.format(self)
    }
}


extension GeoURI {
    static let numberStyle = FloatingPointFormatStyle<Double>()
        // 8 decimal places represents 1.1132 mm at the equator.
        .precision(.fractionLength(0...8))
        .sign(strategy: .automatic)
        .grouping(.never)
        .decimalSeparator(strategy: .automatic)
}
