import Foundation

public extension GeoURI {
    struct FormatStyle {
        let includeCRS: Bool
        
        public init(includeCRS: Bool = true) {
            self.includeCRS = includeCRS
        }
        
        // MARK: Customization Method Chaining

        public func includeCRS(_ includeCRS: Bool) -> Self {
            .init(includeCRS: includeCRS)
        }
    }
}

extension GeoURI.FormatStyle: Foundation.FormatStyle {
    public typealias ParseInput = GeoURI
    public typealias ParseOutput = String
    
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

extension FormatStyle where Self == GeoURI.FormatStyle {
    static var full:  GeoURI.FormatStyle { .init(includeCRS: true) }
    static var short:  GeoURI.FormatStyle { .init(includeCRS: false) }
}


public extension GeoURI {
    /// Converts `self` to its textual representation.
    /// - Returns: String
    func formatted(includeCRS: Bool = true) -> String {
        Self.FormatStyle(includeCRS: includeCRS).format(self)
    }
    
    /// Converts `self` to another representation.
    /// - Parameter style: The format for formatting `self`
    /// - Returns: A representations of `self` using the given `style`. The type of the return is determined by the FormatStyle.FormatOutput
    func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == GeoURI {
        style.format(self)
    }
}

// MARK: - Parsing

public extension GeoURI.FormatStyle {
    struct ParseStrategy: Foundation.ParseStrategy {
        public typealias ParseInput = String
        public typealias ParseOutput = GeoURI
        
        public func parse(_ value: String) throws -> GeoURI {
            return try GeoURI(string: value.trimmingCharacters(in: .whitespaces))
        }
    }
}

extension GeoURI.FormatStyle: ParseableFormatStyle {
    public var parseStrategy: GeoURI.FormatStyle.ParseStrategy {
        .init()
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
