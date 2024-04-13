#if canImport(CoreLocation)

import CoreLocation

extension GeoURI {
    /// Creates a new ``GeoURI`` from a `CLLocationCoordinate2D`.
    public convenience init(coordinate: CLLocationCoordinate2D) throws {
        try self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    /// Creates a new ``GeoURI`` from a `CLLocation` object.
    public convenience init(location: CLLocation) throws {
        try self.init(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude,
            uncertainty: location.horizontalAccuracy
        )
    }
    
    /// The two dimensional location of the ``GeoURI``, expressed as CLLocationCoordinate2D.
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// The location of the ``GeoURI``, expressed as a `CLLocation` object.
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
