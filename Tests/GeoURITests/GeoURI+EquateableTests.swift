import XCTest
import GeoURI

final class GeoURI_EquateableTests: XCTestCase {

    func testsLatitudeEquality() throws {
        let a = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        let b = try GeoURI(latitude: 48.20101, longitude: 16.3695)
        XCTAssertNotEqual(a, b)
    }
    
    func testsLongitudeEquality() throws {
        let a = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        let b = try GeoURI(latitude: 48.2010, longitude: 16.36951)
        XCTAssertNotEqual(a, b)
    }
    
    func testsAltitudeEquality() throws {
        let a = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        var b = a
        XCTAssertEqual(a, b)
        
        b = try GeoURI(latitude: 48.2010, longitude: 16.36951)
        XCTAssertNotEqual(a, b)
        
        let c = try GeoURI(latitude: 48.2010, longitude: 16.36951, altitude: 0)
        XCTAssertNotEqual(b, c)
        
        b = try GeoURI(latitude: 48.2010, longitude: 16.36951, altitude: 1830.01)
        XCTAssertNotEqual(a, b)
    }
    
    func testsUncertaintyEquality() throws {
        let a = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 1.0)
        var b = a
        XCTAssertEqual(a, b)
        
        b = try GeoURI(latitude: 48.2010, longitude: 16.36951)
        XCTAssertNotEqual(a, b)
        
        let c = try GeoURI(latitude: 48.2010, longitude: 16.36951, uncertainty: 0)
        XCTAssertNotEqual(b, c)
        
        b = try GeoURI(latitude: 48.2010, longitude: 16.36951, uncertainty: 1.01)
        XCTAssertNotEqual(a, b)
    }
}
