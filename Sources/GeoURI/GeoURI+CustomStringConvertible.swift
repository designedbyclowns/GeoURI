import Foundation

extension GeoURI: CustomStringConvertible {
    public var description: String {
        let path = [latitude, longitude, altitude].compactMap { $0 }
            .compactMap { Self.numberFormatter.string(from: NSNumber(value: $0)) }
            .joined(separator: ",")
        
        var desc =  "geo:\(path);crs=\(crs.rawValue)"
        
        if let uncertainty, let uVal = Self.numberFormatter.string(from: NSNumber(value: uncertainty)) {
            desc.append(";u=\(uVal)")
        }
        
        return desc
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
