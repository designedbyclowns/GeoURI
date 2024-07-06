import Testing
@testable import GeoURI

struct FormatStyleTests {
    @Test func formatted() async throws {
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.formatted() == "geo:48.201,16.3695;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        #expect(geoURI.formatted() == "geo:48.201,16.3695,183;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183, uncertainty: 66.60)
        #expect(geoURI.formatted() == "geo:48.201,16.3695,183;crs=wgs84;u=66.6")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.60)
        #expect(geoURI.formatted() == "geo:48.201,16.3695;crs=wgs84;u=66.6")
    }
    
    @Test func fullStyle() async throws {
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.formatted(.full) == "geo:48.201,16.3695;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        #expect(geoURI.formatted(.full) == "geo:48.201,16.3695,183;crs=wgs84")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183, uncertainty: 66.60)
        #expect(geoURI.formatted(.full) == "geo:48.201,16.3695,183;crs=wgs84;u=66.6")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.60)
        #expect(geoURI.formatted(.full) == "geo:48.201,16.3695;crs=wgs84;u=66.6")
    }
    
    @Test func shortStyle() async throws {
        var geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        #expect(geoURI.formatted(.short) == "geo:48.201,16.3695")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        #expect(geoURI.formatted(.short) == "geo:48.201,16.3695,183")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183, uncertainty: 66.60)
        #expect(geoURI.formatted(.short) == "geo:48.201,16.3695,183;u=66.6")
        
        geoURI = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 66.60)
        #expect(geoURI.formatted(.short) == "geo:48.201,16.3695;u=66.6")
    }

    @Test(arguments: [
        "geo:48.2010,16.3695",
        "geo:-48.2010,-16.3695,300;crs=wgs84;u=10",
        "geo:-48.2010,-16.3695,-30.0;u=10",
        "geo:90.0,180.0",
        "geo:-90.0,-180.0",
        "geo:90.0,180",
        "geo:-90.0,-180",
        " geo:48.2010,16.3695",
    ]) func validStrings(_ value: String) {
        #expect(throws: Never.self) {
            _ = try GeoURI.FormatStyle().parseStrategy.parse(value)
        }
    }
    
    @Test(arguments: [
        "48.2010,16.3695",
        "geo: 48.2010,16.3695",
        "geo://48.2010,16.3695",
        "xyz:48.2010,16.3695"
    ]) func malformedStrings(_ value: String) {
        #expect(throws: GeoURIError.malformed) {
            _ = try GeoURI.FormatStyle().parseStrategy.parse(value)
        }
    }
}
