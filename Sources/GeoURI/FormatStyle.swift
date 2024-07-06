import Foundation

public extension GeoURI {
    struct FormatStyle: Foundation.FormatStyle {
        
        public var includeCRS: Bool
        
        public init(includeCRS: Bool = true) {
            self.includeCRS = includeCRS
        }
        
        // MARK: Customization Method Chaining

        public func includeCRS(_ includeCRS: Bool) -> Self {
            .init(includeCRS: includeCRS)
        }
        
        // MARK: FormatStyle
        
        public typealias FormatInput = GeoURI
        public typealias FormatOutput = String
        
        public func format(_ value: GeoURI) -> String {
            let path = [value.latitude, value.longitude, value.altitude]
                .compactMap { $0 }
                .compactMap { $0.formatted(GeoURI.numberStyle) }
                .joined(separator: ",")
            
            var str = "geo:\(path)"
            
            if includeCRS {
                str.append(";crs=\(value.crs.rawValue)")
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
    public func formatted(includeCRS: Bool = true) -> String {
        Self.FormatStyle(includeCRS: includeCRS).format(self)
    }
    
    /// Converts `self` to another representation.
    /// - Parameter style: The format for formatting `self`
    /// - Returns: A representations of `self` using the given `style`. The type of the return is determined by the FormatStyle.FormatOutput
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
