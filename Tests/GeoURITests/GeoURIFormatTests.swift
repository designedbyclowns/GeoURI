import Testing
@testable import GeoURI

struct GeoURIFormatTests {

    @Test func format() async throws {
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(GeoURIFormat().format(geoURI) == "geo:48.201,16.3695;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        #expect(GeoURIFormat().format(geoURI) == "geo:48.201,16.3695,183;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183, uncertainty: 66.60)
        #expect(GeoURIFormat().format(geoURI) == "geo:48.201,16.3695,183;crs=wgs84;u=66.6")
                
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.60)
        #expect(GeoURIFormat().format(geoURI) == "geo:48.201,16.3695;crs=wgs84;u=66.6")
    }
    
    @Test func formatted() async throws {
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.formatted(.uri) == "geo:48.201,16.3695;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        #expect(geoURI.formatted(.uri) == "geo:48.201,16.3695,183;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183, uncertainty: 66.60)
        #expect(geoURI.formatted(.uri) == "geo:48.201,16.3695,183;crs=wgs84;u=66.6")
                
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.60)
        #expect(geoURI.formatted(.uri) == "geo:48.201,16.3695;crs=wgs84;u=66.6")
    }

}
