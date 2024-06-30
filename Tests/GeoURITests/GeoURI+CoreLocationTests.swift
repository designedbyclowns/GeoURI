#if canImport(CoreLocation)

import Testing
import CoreLocation
@testable import GeoURI

struct GeoURI_CoreLocationTests {
    
    // MARK: - Coordinate Initialization
    
    @Test func initWithCoordinate() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: 16.3695)
        let geoURI = try GeoURI(coordinate: coordinate)
        
        #expect(geoURI.latitude == 48.201)
        #expect(geoURI.longitude == 16.3695)
        #expect(geoURI.altitude == nil)
        #expect(geoURI.crs == .wgs84)
        #expect(geoURI.uncertainty == nil)
    }
    
    @Test(arguments: [90.01, -90.01])
    func invalidCoordinateLatitude(arg: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: arg, longitude: 16.3695)
        
        #expect(throws: GeoURIError.invalidLatitude) {
            try GeoURI(coordinate: coordinate)
        }
    }
    
    @Test(arguments: [180.01, -180.01])
    func invalidCoordinateLongitude(arg: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: arg)
        
        #expect(throws: GeoURIError.invalidLongitude) {
            try GeoURI(coordinate: coordinate)
        }
    }
   
    @Test(arguments: [90, -90])
    func polarCoordinates(arg: CLLocationDegrees) throws {
        let coordinate = CLLocationCoordinate2D(latitude: arg, longitude: 16.3695)
        let geoURI = try GeoURI(coordinate: coordinate)
        #expect(geoURI.longitude == .zero)
    }
    
    @Test(arguments: [180, -180])
    func datelineCoordinates(arg: CLLocationDegrees) throws {
        let coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: arg)
        let geoURI = try GeoURI(coordinate: coordinate)
        #expect(geoURI.longitude == 180.0)
    }
    
    // MARK: - Location Initialization
    
    @Test func initWithLocation() throws {
        let location = CLLocation(latitude: 48.2010, longitude: 16.3695)
        let geoURI = try GeoURI(location: location)
        
        #expect(geoURI.latitude == 48.201)
        #expect(geoURI.longitude == 16.3695)
        #expect(geoURI.altitude == .zero)
        #expect(geoURI.crs == .wgs84)
        #expect(geoURI.uncertainty == .zero)
    }
    
    @Test func initWithFullLocation() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: 16.3695)
        
        let location = CLLocation(
            coordinate: coordinate,
            altitude: 183,
            horizontalAccuracy: 1.0,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
        
        let geoURI = try GeoURI(location: location)
        
        #expect(geoURI.latitude == 48.201)
        #expect(geoURI.longitude == 16.3695)
        #expect(geoURI.altitude == 183.0)
        #expect(geoURI.crs == .wgs84)
        #expect(geoURI.uncertainty == 1.0)
    }
    
    @Test(arguments: [90.01, -90.01])
    func invalidLocationLatitude(arg: CLLocationDegrees) {
        let location = CLLocation(latitude: arg, longitude: 16.3695)
        
        #expect(throws: GeoURIError.invalidLatitude) {
            try GeoURI(location: location)
        }
    }
    
    @Test(arguments: [180.01, -180.01])
    func invalidLocationLongitude(arg: CLLocationDegrees) {
        let location = CLLocation(latitude: 48.2010, longitude: arg)
        
        #expect(throws: GeoURIError.invalidLongitude) {
            try GeoURI(location: location)
        }
    }
    
    @Test func invalidUncertainty() {
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 48.2010, longitude: 16.3695),
            altitude: 183,
            horizontalAccuracy: -1,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
        
        #expect(throws: GeoURIError.invalidUncertainty) {
            try GeoURI(location: location)
        }
    }
    
    // MARK: - Coordinate Generation
    
    @Test func coordinate() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        
        #expect(geoURI.coordinate.latitude == 48.201)
        #expect(geoURI.coordinate.longitude == 16.3695)
    }
    
    // MARK: - Location Generation
    
    @Test func location() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        
        #expect(geoURI.location.coordinate.latitude == 48.201)
        #expect(geoURI.location.coordinate.longitude == 16.3695)
        #expect(geoURI.location.altitude == .zero)
        #expect(geoURI.location.horizontalAccuracy == .zero)
        #expect(geoURI.location.verticalAccuracy == .zero)
    }
    
    @Test func locationWithAltitude() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: -183)
        
        #expect(geoURI.location.coordinate.latitude == 48.201)
        #expect(geoURI.location.coordinate.longitude == 16.3695)
        #expect(geoURI.location.altitude == -183.0)
        #expect(geoURI.location.horizontalAccuracy == .zero)
        #expect(geoURI.location.verticalAccuracy == .zero)
    }
    
    @Test func locationWithUncertanity() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 1.0)
        
        #expect(geoURI.location.coordinate.latitude == 48.201)
        #expect(geoURI.location.coordinate.longitude == 16.3695)
        #expect(geoURI.location.altitude == .zero)
        #expect(geoURI.location.horizontalAccuracy == 1.0)
        #expect(geoURI.location.verticalAccuracy == .zero)
    }
}

#endif
