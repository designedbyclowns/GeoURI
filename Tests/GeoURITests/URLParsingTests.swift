import XCTest
@testable import GeoURI

final class URLParsingTests: XCTestCase {
    
    var geoURL: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        geoURL = try XCTUnwrap(URL(string: "geo:48.2010,16.3695"))
    }
    
    override func tearDownWithError() throws {
        geoURL = nil
        try super.tearDownWithError()
    }
    
    func testInitWithURL() throws {
        let geoURI = try GeoURI(url: geoURL)
        
        XCTAssertEqual(48.2010, geoURI.latitude)
        XCTAssertEqual(16.3695, geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        XCTAssertEqual(GeoURI.CoordinateReferenceSystem.wgs84, geoURI.crs)
        XCTAssertNil(geoURI.uncertainty)
    }
    
    func testUrlSchemeParsing() throws {
        _ = try GeoURI(url: geoURL)
        
        // Should be case-insensitive
        var url = try XCTUnwrap(URL(string: "GEO:48.2010,16.3695"))
        _ = try GeoURI(url: url)
        
        // An invalid scheme should throw an incorrectScheme parsing error
        url = try XCTUnwrap(URL(string: "xxx:48.2010,16.3695,183"))
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .incorrectScheme))
        }
    }
    
    func testUrlPathParsing() throws {
        var url = try XCTUnwrap(URL(string: "geo:48.2010,16.3695"))
        var geoURI = try GeoURI(url: url)
        XCTAssertEqual(48.2010, geoURI.latitude)
        XCTAssertEqual(16.3695, geoURI.longitude)
        XCTAssertNil(geoURI.altitude)
        
        url = try XCTUnwrap(URL(string: "geo:48.2010,16.3695,183"))
        geoURI = try GeoURI(url: url)
        XCTAssertEqual(48.2010, geoURI.latitude)
        XCTAssertEqual(16.3695, geoURI.longitude)
        XCTAssertEqual(183, geoURI.altitude)
        
        // Too many numeric values
        url = try XCTUnwrap(URL(string: "geo:48.2010,16.3695,183,666"))
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .badURL))
        }
        
        // should not have a space
        url = try XCTUnwrap(URL(string: "geo:48.2010, 16.3695"))
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .badURL))
        }
        
        // parsed path values should all be numeric
        url = try XCTUnwrap(URL(string: "geo:48.2010,16.3695,xxx"))
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .badURL))
        }
    
    }
    
    func testLatitudeBounds() throws {
        var url = try XCTUnwrap(URL(string: "geo:90,16.3695"))
        var geoURI = try GeoURI(url: url)
        XCTAssertEqual(Double(90), geoURI.latitude)
        
        url = try XCTUnwrap(URL(string: "geo:90.000001,16.3695"))
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .invalidLatitude))
        }
        
        url = try XCTUnwrap(URL(string: "geo:-90,16.3695"))
        geoURI = try GeoURI(url: url)
        XCTAssertEqual(Double(-90), geoURI.latitude)
        
        url = try XCTUnwrap(URL(string: "geo:-90.000001,16.3695"))
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .invalidLatitude))
        }
    }
    
    func testLongitudeBounds() throws {
        var url = try XCTUnwrap(URL(string: "geo:48.2010,180"))
        let geoURI = try GeoURI(url: url)
        XCTAssertEqual(Double(180), geoURI.longitude)
        
        url = try XCTUnwrap(URL(string: "geo:48.2010,180.00000001"))
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .invalidLongitude))
        }
        
        url = try XCTUnwrap(URL(string: "geo:48.2010,-180.00000001"))
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .invalidLongitude))
        }
    }
    
    func testDatelineLongitude() throws {
        let url = try XCTUnwrap(URL(string: "geo:48.2010,-180"))
        let geoURI = try GeoURI(url: url)
        XCTAssertEqual(Double(180), geoURI.longitude)
    }
    
    func testPolarLongitude() throws {
        let northPole = try XCTUnwrap(URL(string: "geo:90,16.3695"))
        var geoURI = try GeoURI(url: northPole)
        XCTAssertEqual(Double.zero, geoURI.longitude)
        
        let southPole = try XCTUnwrap(URL(string: "geo:-90,16.3695"))
        geoURI = try GeoURI(url: southPole)
        XCTAssertEqual(Double.zero, geoURI.longitude)
    }
    
    func testAltitude() throws {
        let url = try XCTUnwrap(geoURL)
        var geoURI = try GeoURI(url: url)
        XCTAssertNil(geoURI.altitude)
        
        let mountEverest = try XCTUnwrap(URL(string: "geo:27.988056,86.925278,8848.86"))
        geoURI = try GeoURI(url: mountEverest)
        XCTAssertEqual(Double(8_848.86), geoURI.altitude)
        
        let pointNemo = try XCTUnwrap(URL(string: "geo:-48.876667,-123.393333,0"))
        geoURI = try GeoURI(url: pointNemo)
        XCTAssertEqual(Double.zero, geoURI.altitude)
        
        let challengerDeep = try XCTUnwrap(URL(string: "geo:11.373333,142.591667,-10920"))
        geoURI = try GeoURI(url: challengerDeep)
        XCTAssertEqual(Double(-10_920), geoURI.altitude)
    }
    
    func testCrsQuertyItem() throws {
        var url = try XCTUnwrap(geoURL)
        var geoURI = try GeoURI(url: url)
        XCTAssertEqual(.wgs84, geoURI.crs)
        
        var item = URLQueryItem(name: "crs", value: "wgs84")
        
        url = geoURL.appending(queryItems: [item])
        geoURI = try GeoURI(url: url)
        XCTAssertEqual(.wgs84, geoURI.crs)
        
        // value should be case-insensitive
        item.value = "WGS84"
        url = geoURL.appending(queryItems: [item])
        geoURI = try GeoURI(url: url)
        XCTAssertEqual(.wgs84, geoURI.crs)
        
        // unsupported CRS
        item.value = "nad27"
        url = geoURL.appending(queryItems: [item])
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .unsupportedCoordinateReferenceSystem("nad27")))
        }
        
        // parameter should only be provided once
        item.value = "wgs84"
        url = geoURL.appending(queryItems: [item, item])
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .duplicateQueryItem(name: "crs")))
        }
        
        // parameter should not be nil
        item.value = nil
        url = geoURL.appending(queryItems: [item])
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .invalidQueryItem(name: "crs")))
        }
        
        // parameter name should be case-insensitive
        item = URLQueryItem(name: "CRS", value: "wgs84")
        url = geoURL.appending(queryItems: [item])
        geoURI = try GeoURI(url: url)
        XCTAssertEqual(.wgs84, geoURI.crs)
    }
    
    func testUncertaintyQuertyItem() throws {
        var url = try XCTUnwrap(geoURL)
        var geoURI = try GeoURI(url: url)
        XCTAssertNil(geoURI.uncertainty)
        
        var item = URLQueryItem(name: "u", value: "66.6")
        
        url = geoURL.appending(queryItems: [item])
        geoURI = try GeoURI(url: url)
        XCTAssertEqual(Double(66.6), geoURI.uncertainty)
        
        // uncertainty should be >= 0
        item.value = "-0.0000001"
        url = geoURL.appending(queryItems: [item])
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .invalidUncertainty))
        }
        
        item.value = "0"
        url = geoURL.appending(queryItems: [item])
        geoURI = try GeoURI(url: url)
        XCTAssertEqual(Double.zero, geoURI.uncertainty)
        
        // uncertainty should be numeric
        item.value = "very"
        url = geoURL.appending(queryItems: [item])
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
           XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .invalidUncertainty))
        }
        
        // parameter should only be provided once
        item = URLQueryItem(name: "u", value: "123")
        url = geoURL.appending(queryItems: [item, item])
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .duplicateQueryItem(name: "u")))
        }
        
        // parameter should not be nil
        item.value = nil
        url = geoURL.appending(queryItems: [item])
        XCTAssertThrowsError(try GeoURI(url: url)) { error in
            XCTAssertEqual(error as? GeoURIParsingError, GeoURIParsingError(url: url, kind: .invalidQueryItem(name: "u")))
        }
        
        // parameter name should be case-insensitive
        item = URLQueryItem(name: "U", value: "123")
        url = geoURL.appending(queryItems: [item])
        geoURI = try GeoURI(url: url)
        XCTAssertEqual(Double(123), geoURI.uncertainty)
    }
}
