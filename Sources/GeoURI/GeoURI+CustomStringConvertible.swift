import Foundation

extension GeoURI: CustomStringConvertible {
    public var description: String {
        self.formatted(.full)
    }
}

extension GeoURI: CustomDebugStringConvertible {
    public var debugDescription: String {
        [
            "latitude: \(String(describing: latitude))",
            "longitude: \(String(describing: longitude))",
            "altitude: \(String(describing: altitude))",
            "crs: \(crs.rawValue)",
            "uncertainty: \(String(describing: uncertainty))"
        ].joined(separator: ", ")
    }
}
