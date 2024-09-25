import Testing
import Foundation
@testable import GeoURI

struct GeoURI_URLTests {
    
    @Test func initWithURL() throws {
        let url = try #require(URL(string: "geo:48.2010,16.3695"))
        let geoURI = try GeoURI(url: url)
        
        #expect(geoURI.latitude == 48.2010)
        #expect(geoURI.longitude == 16.3695)
        #expect(geoURI.altitude == nil)
        #expect(geoURI.crs == GeoURI.CoordinateReferenceSystem.wgs84)
        #expect(geoURI.uncertainty == nil)
    }
    
    @Suite struct URLParsing  {
        @Test(arguments: [
            "geo:48.2010,16.3695",
            "geo:48.2010,16.3695,183",
            "geo:-48.2010,-16.3695,-183.6",
            "GEO:48.2010,16.3695"
        ]) func urlParsing(arg: String) throws {
            let url = try #require(URL(string: arg))
            #expect(throws: Never.self) {
                try GeoURI(url: url)
            }
        }
        
        @Test(arguments: [
            "geo:48.2010,16.3695,183,666",
            "geo:48.2010, 16.3695",
            "geo:48.2010,16.3695,xxx"
        ]) func badURL(arg: String) throws {
            let url = try #require(URL(string: arg))
            #expect(throws: GeoURIParsingError(url: url, kind: .badURL)) {
                try GeoURI(url: url)
            }
        }
        
        @Test(arguments: [
            "xxx:48.2010,16.3695,183",
            "geos:48.2010, 16.3695",
        ]) func incorrectScheme(arg: String) throws {
            let url = try #require(URL(string: arg))
            #expect(throws: GeoURIParsingError(url: url, kind: .incorrectScheme)) {
                try GeoURI(url: url)
            }
        }
    }
    
    /**
     'geo' URIs with longitude values outside the range of -180 to 180
     decimal degrees or with latitude values outside the range of -90 to
     90 degrees MUST be considered invalid.
     
     https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.2
     */
    @Suite struct LatitudeBounds {
        @Test(arguments: [
            "geo:90,16.3695",
            "geo:-90,16.3695"
        ])
        func validLatitude(arg: String) throws {
            let url = try #require(URL(string: arg))
            #expect(throws: Never.self) {
                try GeoURI(url: url)
            }
        }
        
        @Test(arguments: [
            "geo:90.000001,16.3695",
            "geo:-90.000001,16.3695",
        ])
        func invalidLatitude(arg: String) throws {
            let url = try #require(URL(string: arg))
            #expect(throws: GeoURIParsingError(url: url, kind: .invalidLatitude)) {
                try GeoURI(url: url)
            }
        }
    }
    
    /**
     'geo' URIs with longitude values outside the range of -180 to 180
     decimal degrees or with latitude values outside the range of -90 to
     90 degrees MUST be considered invalid.
     
     https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.2
     */
    @Suite struct LongitudeBounds {
        @Test(arguments: [
            "geo:48.2010,180",
            "geo:48.2010,-180",
        ])
        func validLongitude(arg: String) throws {
            let url = try #require(URL(string: arg))
            #expect(throws: Never.self) {
                try GeoURI(url: url)
            }
        }
        
        @Test(arguments: [
            "geo:48.2010,180.00000001",
            "geo:48.2010,-180.00000001",
        ])
        func invalidLongitude(arg: String) throws {
            let url = try #require(URL(string: arg))
            #expect(throws: GeoURIParsingError(url: url, kind: .invalidLongitude)) {
                try GeoURI(url: url)
            }
        }
        
        /**
         A <longitude> of 180 degrees MUST be considered equal to
         <longitude> of -180 degrees for the purpose of URI comparison
         ("date line" case).
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.4
         */
        @Test func dateLine() throws {
            let url = try #require(URL(string: "geo:48.2010,-180"))
            let geoURI = try GeoURI(url: url)
            #expect(geoURI.longitude == 180.0)
        }
        
        /**
         The <longitude> of coordinate values reflecting the poles (<latitude>
         set to -90 or 90 degrees) SHOULD be set to "0", although consumers of
         'geo' URIs MUST accept such URIs with any longitude value from -180
         to 180.
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.2
         */
        @Test(arguments: [
            "geo:90,16.3695",
            "geo:-90,16.3695"
        ])
        func polarLongitudes(arg: String) throws {
            let url = try #require(URL(string: arg))
            let geoURI = try GeoURI(url: url)
            #expect(geoURI.longitude == .zero)
        }
    }
    
    @Test(arguments: [
        ("geo:48.2010,16.3695", nil),
        ("geo:27.988056,86.925278,8848.86", 8_848.86), // Mount Everest
        ("geo:-48.876667,-123.393333,0", .zero), // Point Nemo
        ("geo:11.373333,142.591667,-10920", -10_920) // Challenger Deep
    ]) func altitude(arg: (String, Double?)) throws {
        let url = try #require(URL(string: arg.0))
        let geoURI = try GeoURI(url: url)
        #expect(geoURI.altitude == arg.1)
    }
    
    
    @Suite struct CRSQueryItem {
        @Test(arguments: [
            "geo:48.2010,16.3695",
            "geo:48.2010,16.3695?crs=wgs84",
            "geo:48.2010,16.3695?crs=WGS84",
            "geo:48.2010,16.3695?CRS=wgs84",
        ]) func crs(arg: String) throws {
            let url = try #require(URL(string: arg))
            let geoURI = try GeoURI(url: url)
            #expect(geoURI.crs == .wgs84)
        }
        
        // parameter should only be provided once
        @Test func duplicateQueryItem() throws {
            let geoURL = try #require(URL(string: "geo:48.2010,16.3695"))
            let queryItem = URLQueryItem(name: "crs", value: "wgs84")
            let url = geoURL.appending(queryItems: [queryItem, queryItem])
            #expect(throws: GeoURIParsingError(url: url, kind: .duplicateQueryItem(name: "crs"))) {
                try GeoURI(url: url)
            }
        }
        
        // parameter value should not be nil
        @Test func invalidQueryItem() throws {
            let url = try #require(URL(string: "geo:48.2010,16.3695?crs"))
            #expect(throws: GeoURIParsingError(url: url, kind: .invalidQueryItem(name: "crs"))) {
                try GeoURI(url: url)
            }
        }
    }
    
    /**
     The 'u' parameter is optional and it can appear only once.  If it is
     not specified, this indicates that uncertainty is unknown or
     unspecified.  If the intent is to indicate a specific point in space,
     <uval> MAY be set to zero.  Zero uncertainty and absent uncertainty
     are never the same thing.
     
     https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.3
     */
    @Suite struct UncertaintyQueryItem {
        @Test(arguments: [
            ("geo:48.2010,16.3695", nil),
            ("geo:48.2010,16.3695?u=66.6", 66.6),
            ("geo:48.2010,16.3695?u=0", .zero),
            ("geo:48.2010,16.3695?U=123", 123.0)
        ])  func uncertainty(arg: (String, Double?)) throws {
            let url = try #require(URL(string: arg.0))
            let geoURI = try GeoURI(url: url)
            #expect(geoURI.uncertainty == arg.1)
        }
        
        @Test(arguments: [
            "geo:48.2010,16.3695?u=-0.0000001",
            "geo:48.2010,16.3695?u=very",
            "geo:48.2010,16.3695?u=",
        ]) func invalidUncertainty(arg: String) throws {
            let url = try #require(URL(string: arg))
            #expect(throws: GeoURIParsingError(url: url, kind: .invalidUncertainty)) {
                try GeoURI(url: url)
            }
        }
        
        // parameter should only be provided once
        @Test func duplicateQueryItem() throws {
            let geoURL = try #require(URL(string: "geo:48.2010,16.3695"))
            let queryItem = URLQueryItem(name: "u", value: "1.0")
            let url = geoURL.appending(queryItems: [queryItem, queryItem])
            #expect(throws: GeoURIParsingError(url: url, kind: .duplicateQueryItem(name: "u"))) {
                try GeoURI(url: url)
            }
        }
        
        // parameter value should not be nil
        @Test func invalidQueryItem() throws {
            let url = try #require(URL(string: "geo:48.2010,16.3695?u"))
            #expect(throws: GeoURIParsingError(url: url, kind: .invalidQueryItem(name: "u"))) {
                try GeoURI(url: url)
            }
        }
    }
    
    @Suite struct URLGeneration {
        
        @Test func url() throws {
            var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
            var url = try #require(URL(string: "geo:48.201,16.3695?crs=wgs84"))
            #expect(geoURI.url == url)
            
            geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
            url = try #require(URL(string: "geo:48.201,16.3695,183?crs=wgs84"))
            #expect(geoURI.url == url)
            
            geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 123.45, uncertainty: 666)
            url = try #require(URL(string: "geo:48.201,16.3695,123.45?crs=wgs84&u=666"))
            #expect(geoURI.url == url)
        }
        
        @Test func polarURL() throws {
            var geoURI = try GeoURI(latitude: 90.0, longitude: 16.3695)
            var url = try #require(URL(string: "geo:90,0?crs=wgs84"))
            #expect(geoURI.url == url)
            
            geoURI = try GeoURI(latitude: -90.0, longitude: 16.3695)
            url = try #require(URL(string: "geo:-90,0?crs=wgs84"))
            #expect(geoURI.url == url)
        }
        
        @Test func datelineURL() throws {
            var geoURI = try GeoURI(latitude: 48.2010, longitude: 180.0)
            var url = try #require(URL(string: "geo:48.201,180?crs=wgs84"))
            #expect(geoURI.url == url)
            
            geoURI = try GeoURI(latitude: 48.2010, longitude: -180.0)
            url = try #require(URL(string: "geo:48.201,180?crs=wgs84"))
            #expect(geoURI.url == url)
        }
    }
}
