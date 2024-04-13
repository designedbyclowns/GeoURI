import XCTest
@testable import GeoURI

final class StringParsingTests: XCTestCase {

    func testInitWithString() throws {
        let geoURI = try GeoURI(string: "geo:48.2010,16.3695")
        
        XCTAssertEqual(48.2010, geoURI.latitude)
        XCTAssertEqual(16.3695, geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        XCTAssertEqual(GeoURI.CoordinateReferenceSystem.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
    }
    
    func testSchemeParsing() throws {
        var str = "geo:48.2010,16.3695"
        _ = try GeoURI(string: str)
                
        str = "GEO:48.2010,16.3695"
        _ = try GeoURI(string: str)
        
        str = "48.2010,16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo: 48.2010,16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo://48.2010,16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = " geo:48.2010,16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "xyz:48.2010,16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
    }
    
    func testCoordinateParsing() throws {
        var str = "geo:48.2010,16.3695"
        var geoURI = try GeoURI(string: str)
        XCTAssertEqual(48.2010, geoURI.latitude)
        XCTAssertEqual(16.3695, geoURI.longitude)
        
        str = "geo:-48.2010,-16.3695"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(-48.2010, geoURI.latitude)
        XCTAssertEqual(-16.3695, geoURI.longitude)
        
        str = "geo:"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,abc"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010, 16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010;16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
    }
    
    func testLatitudeParsing() throws {
        var str = "geo:48.2010,16.3695"
        var geoURI = try GeoURI(string: str)
        XCTAssertEqual(48.2010, geoURI.latitude)
        
        str = "geo:-48.2010,-16.3695"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(-48.2010, geoURI.latitude)
        
        str = "geo:48.2010"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:latitude=48.2010,"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:90.01,16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLatitude)
        }
        
        str = "geo:-90.01,16.3695"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLatitude)
        }
    }
    
    func testLongitudeParsing() throws {
        var str = "geo:48.2010,16.3695"
        var geoURI = try GeoURI(string: str)
        XCTAssertEqual(16.3695, geoURI.longitude)
        
        str = "geo:48.2010,-16.3695"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(-16.3695, geoURI.longitude)
        
        str = "geo:48.2010,16.3695,"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,16.3695 "
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,xyz"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,180.01"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLongitude)
        }
        
        str = "geo:48.2010,-180.01"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidLongitude)
        }
    }
    
    func testAltitudeParsing() throws {
        var str = "geo:48.2010,16.3695,666"
        var geoURI = try GeoURI(string: str)
        XCTAssertEqual(48.2010, geoURI.latitude)
        XCTAssertEqual(16.3695, geoURI.longitude)
        XCTAssertEqual(666, geoURI.altitude)
        
        str = "geo:48.2010,16.3695,-66.6"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(-66.6, geoURI.altitude)
        
        str = "geo:48.2010,16.3695,0"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(Double.zero, geoURI.altitude)
        
        str = "geo:48.2010,16.3695, 666"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,16.3695,high"
        geoURI = try GeoURI(string: str)
        XCTAssertNil(geoURI.altitude)
    }
    
    func testCrsParsing() throws {
        let expected = GeoURI.CoordinateReferenceSystem.wgs84
        
        var str = "geo:48.2010,16.3695;crs=wgs84"
        var geoURI = try GeoURI(string: str)
        XCTAssertEqual(expected, geoURI.crs)
        
        str = "geo:48.2010,16.3695;crs=WGS84"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(expected, geoURI.crs)
        
        str = "geo:48.2010,16.3695;crs=nad27"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .unsupportedCoordinateReferenceSystem("nad27"))
        }
        
        str = "geo:48.2010,16.3695;crs=wgs84 "
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,16.3695;crs="
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,16.3695;crs= wgs84"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,16.3695;crs"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(expected, geoURI.crs)
    }
    
    func testUncertaintyParsing() throws {
        var str = "geo:48.2010,16.3695;u=123.4"
        var geoURI = try GeoURI(string: str)
        XCTAssertEqual(123.4, geoURI.uncertainty)
        
        str = "geo:48.2010,16.3695;u=0"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(Double.zero, geoURI.uncertainty)
        
        str = "geo:48.2010,16.3695;u=-0.01"
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .invalidUncertainty)
        }
        
        str = "geo:48.2010,16.3695;u=very"
        geoURI = try GeoURI(string: str)
        XCTAssertNil(geoURI.uncertainty)
        
        str = "geo:48.2010,16.3695;u="
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,16.3695;u=666 "
        XCTAssertThrowsError(try GeoURI(string: str)) { error in
            XCTAssertEqual(error as? GeoURIError, .malformed)
        }
        
        str = "geo:48.2010,16.3695;u=123;u=666"
        geoURI = try GeoURI(string: str)
        XCTAssertEqual(123, geoURI.uncertainty)
        
        str = "geo:48.2010,16.3695;u"
        geoURI = try GeoURI(string: str)
        XCTAssertNil(geoURI.uncertainty)
    }
}
