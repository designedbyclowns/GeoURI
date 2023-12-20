import XCTest
import GeoURI
import CoreLocation

final class GeoURI_CoreLocationTests: XCTestCase {
    
    // MARK: - init coordinate

    func testInitWithCoordinate() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: 16.3695)
        let geoURI = try GeoURI(coordinate: coordinate)
        
        XCTAssertEqual(coordinate.latitude, geoURI.latitude)
        XCTAssertEqual(coordinate.longitude, geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        XCTAssertEqual(.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
    }
    
    func testInitWithInvalidCoordinateLatitude() throws {
        var coordinate = CLLocationCoordinate2D(latitude: 90.01, longitude: 16.3695)
        XCTAssertThrowsError(try GeoURI(coordinate: coordinate)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLatitude)
        }
        
        coordinate = CLLocationCoordinate2D(latitude: -90.01, longitude: 16.3695)
        XCTAssertThrowsError(try GeoURI(coordinate: coordinate)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLatitude)
        }
    }
    
    func testInitWithInvalidCoordinateLongitude() throws {
        var coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: 180.01)
        XCTAssertThrowsError(try GeoURI(coordinate: coordinate)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLongitude)
        }
        
        coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: -180.01)
        XCTAssertThrowsError(try GeoURI(coordinate: coordinate)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLongitude)
        }
    }
    
    func testInitWithPolarCoordinate() throws {
        // north pole
        var coordinate = CLLocationCoordinate2D(latitude: 90.0, longitude: 16.3695)
        var geoURI = try GeoURI(coordinate: coordinate)
        
        XCTAssertEqual(coordinate.latitude, geoURI.latitude)
        // longitude should be 0
        XCTAssertEqual(Double.zero, geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        XCTAssertEqual(.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
        
        // south pole
        coordinate = CLLocationCoordinate2D(latitude: -90.0, longitude: 16.3695)
        geoURI = try GeoURI(coordinate: coordinate)
        
        XCTAssertEqual(coordinate.latitude, geoURI.latitude)
        // longitude should be 0
        XCTAssertEqual(Double.zero, geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        XCTAssertEqual(.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
    }
    
    func testInitWithDatelineCoordinate() throws {
        var coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: 180)
        var geoURI = try GeoURI(coordinate: coordinate)
        
        XCTAssertEqual(coordinate.latitude, geoURI.latitude)
        XCTAssertEqual(Double(180), geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        XCTAssertEqual(.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
        
        coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: -180)
        geoURI = try GeoURI(coordinate: coordinate)
        
        XCTAssertEqual(coordinate.latitude, geoURI.latitude)
        // longitude should be 180 NOT -180
        XCTAssertEqual(Double(180), geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        XCTAssertEqual(.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
    }
    
    // MARK: - init location

    func testInitWithSimpleLocation() throws {
        let location = CLLocation(latitude: 48.2010, longitude: 16.3695)
        
        let geoURI = try GeoURI(location: location)
        
        XCTAssertEqual(location.coordinate.latitude, geoURI.latitude)
        XCTAssertEqual(location.coordinate.longitude, geoURI.longitude)
        XCTAssertEqual(Double.zero, geoURI.altitude)
        XCTAssertEqual(.wgs84, geoURI.crs)
        XCTAssertEqual(location.horizontalAccuracy, geoURI.uncertainty)
    }
    
    func testInitWithCompleteLocation() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: 16.3695)
        
        let location = CLLocation(
            coordinate: coordinate,
            altitude: 183,
            horizontalAccuracy: 1.0,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
        
        let geoURI = try GeoURI(location: location)
        
        XCTAssertEqual(location.coordinate.latitude, geoURI.latitude)
        XCTAssertEqual(location.coordinate.longitude, geoURI.longitude)
        XCTAssertEqual(location.altitude, geoURI.altitude)
        XCTAssertEqual(.wgs84, geoURI.crs)
        XCTAssertEqual(location.horizontalAccuracy, geoURI.uncertainty)
    }
    
    func testInitWithLocationInvalidLatitude() throws {
                
        var location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 90.01, longitude: 16.3695),
            altitude: 183,
            horizontalAccuracy: .zero,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
        XCTAssertThrowsError(try GeoURI(location: location)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLatitude)
        }
        
        location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: -90.01, longitude: 16.3695),
            altitude: 183,
            horizontalAccuracy: .zero,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
        XCTAssertThrowsError(try GeoURI(location: location)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLatitude)
        }
    }
    
    func testInitWithLocationInvalidLongitude() throws {
        var location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 48.2010, longitude: 180.01),
            altitude: 183,
            horizontalAccuracy: .zero,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
        XCTAssertThrowsError(try GeoURI(location: location)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLongitude)
        }
        
        location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 48.2010, longitude: -180.01),
            altitude: 183,
            horizontalAccuracy: .zero,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
        XCTAssertThrowsError(try GeoURI(location: location)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLongitude)
        }
    }
    
    func testInitWithLocationInvalidUncertainty() throws {
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 48.2010, longitude: 16.3695),
            altitude: 183,
            horizontalAccuracy: -1,
            verticalAccuracy: .zero,
            timestamp: Date()
        )
        XCTAssertThrowsError(try GeoURI(location: location)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidUncertainty)
        }
    }
    
    // MARK: - coordinate
    
    func testCoordinate() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        
        let coordinate = geoURI.coordinate
        XCTAssertEqual(geoURI.latitude, coordinate.latitude)
        XCTAssertEqual(geoURI.longitude, coordinate.longitude)
    }
    
    // MARK: - location
    
    func testLocation() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        let location = geoURI.location
        
        XCTAssertEqual(geoURI.latitude, location.coordinate.latitude)
        XCTAssertEqual(geoURI.longitude, location.coordinate.longitude)
        XCTAssertEqual(Double.zero, location.altitude)
        XCTAssertEqual(Double.zero, location.horizontalAccuracy)
        XCTAssertEqual(Double.zero, location.verticalAccuracy)
    }
    
    func testLocationWihtAltiitude() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: -183)
        let location = geoURI.location
        
        XCTAssertEqual(geoURI.latitude, location.coordinate.latitude)
        XCTAssertEqual(geoURI.longitude, location.coordinate.longitude)
        XCTAssertEqual(Double(-183), location.altitude)
        XCTAssertEqual(Double.zero, location.horizontalAccuracy)
        XCTAssertEqual(Double.zero, location.verticalAccuracy)
    }
    
    func testLocationWithUncertanity() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 666)
        let location = geoURI.location
        
        XCTAssertEqual(geoURI.latitude, location.coordinate.latitude)
        XCTAssertEqual(geoURI.longitude, location.coordinate.longitude)
        XCTAssertEqual(Double.zero, location.altitude)
        XCTAssertEqual(Double(666), location.horizontalAccuracy)
        XCTAssertEqual(Double.zero, location.verticalAccuracy)
    }
}
