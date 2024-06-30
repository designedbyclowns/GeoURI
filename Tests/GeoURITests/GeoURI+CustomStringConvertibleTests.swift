import Testing
import Foundation
@testable import GeoURI

struct GeoURI_CustomStringConvertibleTests {
    
    @Test func description() throws {
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.description == "geo:48.201,16.3695;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        #expect(geoURI.description == "geo:48.201,16.3695,183;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183, uncertainty: 66.60)
        #expect(geoURI.description == "geo:48.201,16.3695,183;crs=wgs84;u=66.6")
                
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.60)
        #expect(geoURI.description == "geo:48.201,16.3695;crs=wgs84;u=66.6")
    }
    
    @Test func debugDescription() throws {
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.debugDescription == "latitude: 48.201, longitude: 16.3695, altitude: nil, crs: wgs84, uncertainty: nil")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        #expect(geoURI.debugDescription == "latitude: 48.201, longitude: 16.3695, altitude: Optional(183.0), crs: wgs84, uncertainty: nil")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183, uncertainty: 66.60)
        #expect(geoURI.debugDescription == "latitude: 48.201, longitude: 16.3695, altitude: Optional(183.0), crs: wgs84, uncertainty: Optional(66.6)")
                
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.60)
        #expect(geoURI.debugDescription == "latitude: 48.201, longitude: 16.3695, altitude: nil, crs: wgs84, uncertainty: Optional(66.6)")
    }
}

