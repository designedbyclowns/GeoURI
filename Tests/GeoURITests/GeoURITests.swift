import Testing
import Foundation
@testable import GeoURI

struct GeoURITests {
    
    @Test func initWithString() throws {
        let geoURI = try GeoURI(string: "geo:48.2010,16.3695")
        
        #expect(geoURI.latitude == 48.2010)
        #expect(geoURI.longitude == 16.3695)
        #expect(geoURI.altitude == nil)
        #expect(geoURI.crs == GeoURI.CoordinateReferenceSystem.wgs84)
        #expect(geoURI.uncertainty == nil)
    }
    
    /**
     'geo' URIs with longitude values outside the range of -180 to 180
     decimal degrees or with latitude values outside the range of -90 to
     90 degrees MUST be considered invalid.
     
     https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.2
     */
    @Suite struct LatitudeBounds {
        @Test(arguments: [90, -90])
        func validLatitude(arg: Double) throws {
            let geoURI = try GeoURI(latitude: arg, longitude: 16.3695)
            #expect(geoURI.latitude == arg)
        }
        
        @Test(arguments: [90.0000000001, -90.0000000001])
        func invalidLatitude(arg: Double) {
            #expect(throws: GeoURIError.invalidLatitude) {
                try GeoURI(latitude: arg, longitude: 16.3695)
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
        @Test(arguments: [180.0, -180])
        func validLongitude(arg: Double) throws {
            let geoURI = try GeoURI(latitude: 48.2010, longitude: arg)
            // NOTE: -180 is coerced to 180 as per the specification.
            #expect(geoURI.longitude == 180.0)
        }
        
        @Test(arguments: [180.0000000001, -180.0000000001])
        func invalidLongitud(arg: Double) {
            #expect(throws: GeoURIError.invalidLatitude) {
                try GeoURI(latitude: arg, longitude: 16.3695)
            }
        }
        
        /**
         A <longitude> of 180 degrees MUST be considered equal to
         <longitude> of -180 degrees for the purpose of URI comparison
         ("date line" case).
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.4
         */
        @Test func dateLine() throws {
            let geoURI = try GeoURI(latitude: 48.2010, longitude: -180)
            #expect(geoURI.longitude == 180.0)
        }
        
        /**
         The <longitude> of coordinate values reflecting the poles (<latitude>
         set to -90 or 90 degrees) SHOULD be set to "0", although consumers of
         'geo' URIs MUST accept such URIs with any longitude value from -180
         to 180.
         
         https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.2
         */
        @Test(arguments: [90.0, -90.0])
        func polarLongitudes(arg: Double) throws {
            let geoURI = try GeoURI(latitude: arg, longitude: 16.3695)
            #expect(geoURI.longitude == .zero)
        }
    }
    
    @Test func altitude() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.altitude == nil)
        
        let pointNemo = try GeoURI(latitude: -48.876667, longitude: -123.393333, altitude: 0)
        #expect(pointNemo.altitude == .zero)
        
        let mountEverest = try GeoURI(latitude: 27.988056, longitude: 86.925278, altitude: 8848.86)
        #expect(mountEverest.altitude == 8_848.86)
        
        let challengerDeep = try GeoURI(latitude: 11.373333, longitude: 142.591667, altitude: -10920)
        #expect(challengerDeep.altitude == -10_920)
    }
    
    @Test func altitudeMeasurement() throws {
        let geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.altitudeMeasurement == nil)
        
        let fitzRoy = try GeoURI(latitude: -49.271278, longitude: -73.043222, altitude: 3405)
        #expect(fitzRoy.altitudeMeasurement?.unit == UnitLength.meters)
        #expect(fitzRoy.altitudeMeasurement?.value == 3_405)
    }
    
    /**
     The 'u' parameter is optional and it can appear only once.  If it is
     not specified, this indicates that uncertainty is unknown or
     unspecified.  If the intent is to indicate a specific point in space,
     <uval> MAY be set to zero.  Zero uncertainty and absent uncertainty
     are never the same thing.
     
     https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.3
     */
    @Test func Uncertainty() throws {
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.uncertainty == nil)
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.6)
        #expect(geoURI.uncertainty == 66.6)
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 0)
        #expect(geoURI.uncertainty == .zero)
        
        #expect(throws: GeoURIError.invalidUncertainty) {
            try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: -0.0000001)
        }
    }
}

