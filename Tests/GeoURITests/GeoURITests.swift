import XCTest
import GeoURI

final class GeoURITests: XCTestCase {

    func testInit() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        XCTAssertEqual(48.2010, geoURI.latitude)
        XCTAssertEqual(16.3695, geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        XCTAssertEqual(GeoURI.CoordinateReferenceSystem.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
    }
    
    func testLatitudeBounds() throws {
        /*
        'geo' URIs with longitude values outside the range of -180 to 180
           decimal degrees or with latitude values outside the range of -90 to
           90 degrees MUST be considered invalid.
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.2
         */
        
        let northPole = try GeoURI(latitude: 90, longitude: 16.3695)
        XCTAssertEqual(90.0, northPole.latitude)
                
        XCTAssertThrowsError(try GeoURI(latitude: 90.0000000001, longitude: 16.3695)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLatitude)
        }
        
        let southPole = try GeoURI(latitude: -90, longitude: 16.3695)
        XCTAssertEqual(-90.0, southPole.latitude)
        
        XCTAssertThrowsError(try GeoURI(latitude: -90.0000000001, longitude: 16.3695)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLatitude)
        }
    }
    
    func testLongitudeBounds() throws {
        /*
        'geo' URIs with longitude values outside the range of -180 to 180
           decimal degrees or with latitude values outside the range of -90 to
           90 degrees MUST be considered invalid.
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.2
         */
        
        // must be <= 180
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 180)
        XCTAssertEqual(180.0, geoURI.longitude)
        
        XCTAssertThrowsError(try GeoURI(latitude: 48.2010, longitude: 180.0000000001)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLongitude)
        }
        
        // must be greater >= -180
        XCTAssertThrowsError(try GeoURI(latitude: 48.2010, longitude: -180.0000000001)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLongitude)
        }
    }
    
    func testDatelineLongitude() throws {
        /*
         A <longitude> of 180 degrees MUST be considered equal to
         <longitude> of -180 degrees for the purpose of URI comparison
         ("date line" case).
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.4
         */
        let geoURI = try GeoURI(latitude: 48.2010, longitude: -180)
        XCTAssertEqual(180.0, geoURI.longitude)
    }
    
    func testPolarLongitude() throws {
        /*
         The <longitude> of coordinate values reflecting the poles (<latitude>
            set to -90 or 90 degrees) SHOULD be set to "0", although consumers of
            'geo' URIs MUST accept such URIs with any longitude value from -180
            to 180.
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.2
         */
        var geoURI = try GeoURI(latitude: 90.0, longitude: 16.3695)
        XCTAssertEqual(.zero, geoURI.longitude)
        
        geoURI = try GeoURI(latitude: -90.0, longitude: 16.3695)
        XCTAssertEqual(.zero, geoURI.longitude)
    }
    
    func testAltitude() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        XCTAssertNil(geoURI.altitude)
        
        let pointNemo = try GeoURI(latitude: -48.876667, longitude: -123.393333, altitude: 0)
        XCTAssertEqual(.zero, pointNemo.altitude)
        
        let mountEverest = try GeoURI(latitude: 27.988056, longitude: 86.925278, altitude: 8848.86)
        XCTAssertEqual(Double(8_848.86), mountEverest.altitude)
        
        let challengerDeep = try GeoURI(latitude: 11.373333, longitude: 142.591667, altitude: -10920)
        XCTAssertEqual(Double(-10_920), challengerDeep.altitude)
    }
    
    func testAltitudeMeasurement() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        XCTAssertNil(geoURI.altitudeMeasurement)
        
        let fitzRoy = try GeoURI(latitude: -49.271278, longitude: -73.043222, altitude: 3405)
        XCTAssertEqual(UnitLength.meters, fitzRoy.altitudeMeasurement?.unit)
        XCTAssertEqual(Double(3_405), fitzRoy.altitudeMeasurement?.value)
    }

    func testUncertainty() throws {
        /*
        The 'u' parameter is optional and it can appear only once.  If it is
           not specified, this indicates that uncertainty is unknown or
           unspecified.  If the intent is to indicate a specific point in space,
           <uval> MAY be set to zero.  Zero uncertainty and absent uncertainty
           are never the same thing.
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.3
         */
        
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        XCTAssertNil(geoURI.uncertainty)
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.6)
        XCTAssertEqual(Double(66.6), geoURI.uncertainty)
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 0)
        XCTAssertEqual(Double.zero, geoURI.uncertainty)
        
        XCTAssertThrowsError(try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: -0.0000001)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidUncertainty)
        }
    }
    
    func testInitWithString() throws {
        let str = "geo:48.2010,16.3695,666"
        let geoURI = try GeoURI(string: str)
        
        XCTAssertEqual(48.2010, geoURI.latitude)
        XCTAssertEqual(16.3695, geoURI.longitude)
        XCTAssertEqual(666, geoURI.altitude)
        XCTAssertEqual(GeoURI.CoordinateReferenceSystem.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
    }
    
    func testInitWithStringCRS() throws {
        var str = "geo:48.2010,16.3695;crs=wgs84"
        var geoURI = try GeoURI(string: str)
        
        XCTAssertEqual(GeoURI.CoordinateReferenceSystem.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
        
        // should be case in-sensitive
        str = "geo:48.2010,16.3695;crs=WgS84"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(GeoURI.CoordinateReferenceSystem.wgs84, geoURI.crs)
    }
    
    func testInitWithStringUnsupportedCRS() throws {
        let str = "geo:48.2010,16.3695;crs=nad27"
        
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .unsupportedCoordinateReferenceSystem("nad27"))
        }
    }
    
    
}
