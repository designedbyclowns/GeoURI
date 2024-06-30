import Foundation

/// A type that converts a ``GeoURI`` into a string representation.
public struct GeoURIFormat: FormatStyle {
    public func format(_ value: GeoURI) -> String {
        let path = [value.latitude, value.longitude, value.altitude]
            .compactMap { $0 }
            .compactMap { $0.formatted(.number.precision(.fractionLength(0...8))) }
            .joined(separator: ",")
        
        var str = "geo:\(path);crs=\(value.crs.rawValue)"
        
        if let uncertainty = value.uncertainty {
            str.append(";u=\(uncertainty.formatted(.number.precision(.fractionLength(0...8))))")
        }
        
        return str
    }
}

extension FormatStyle where Self == GeoURIFormat {
    static var uri: GeoURIFormat { .init() }
}

extension GeoURI {
    func formatted<Style: FormatStyle>(
        _ style: Style
    ) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }
}
