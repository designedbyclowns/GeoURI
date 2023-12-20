#if canImport(CoreLocation)

import CoreLocation

extension GeoURI {
    public init(coordinate: CLLocationCoordinate2D) throws {
        try self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    public init(location: CLLocation) throws {
        try self.init(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude,
            uncertainty: location.horizontalAccuracy
        )
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var location: CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: altitude ?? .zero,
            horizontalAccuracy: uncertainty ?? .zero,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
    }
}

#endif
