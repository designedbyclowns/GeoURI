import Testing
@testable import GeoURI

struct StringParsingTests {

    @Test func InitWithString() throws {
        let geoURI = try GeoURI(string: "geo:48.2010,16.3695")
        
        #expect(geoURI.latitude == 48.2010)
        #expect(geoURI.longitude == 16.3695)
        #expect(geoURI.altitude == nil)
        #expect(geoURI.crs == GeoURI.CoordinateReferenceSystem.wgs84)
        #expect(geoURI.uncertainty == nil)

    }
    
    @Test func InitWithFullString() throws {
        let geoURI = try GeoURI(string: "geo:-48.2010,-16.3695,300;crs=wgs84;u=10")
        
        #expect(geoURI.latitude == -48.201)
        #expect(geoURI.longitude == -16.3695)
        #expect(geoURI.altitude == 300.0)
        #expect(geoURI.crs == GeoURI.CoordinateReferenceSystem.wgs84)
        #expect(geoURI.uncertainty == 10.0)
    }
    
    @Suite struct SchemeParsing {
        @Test(arguments: [
            "geo:48.2010,16.3695",
            "GEO:48.2010,16.3695",
            "GeO:48.2010,16.3695"
        ]) func validScheme(arg: String) {
            #expect(throws: Never.self) {
                _ = try GeoURI(string: arg)
            }
        }
        
        @Test(arguments: [
            "48.2010,16.3695",
            "geo: 48.2010,16.3695",
            "geo://48.2010,16.3695",
            " geo:48.2010,16.3695",
            "xyz:48.2010,16.3695"
        ]) func malformedScheme(arg: String) {
            #expect(throws: GeoURIError.malformed) {
                _ = try GeoURI(string: arg)
            }
        }
    }
    
    @Suite struct CoordinateParsing {
        @Test(arguments: [
            "geo:48.2010,16.3695",
            "geo:-48.2010,-16.3695",
            "geo:90.0,180",
            "geo:-90.0,-180",
        ]) func validCooredinate(arg: String) {
            #expect(throws: Never.self) {
                _ = try GeoURI(string: arg)
            }
        }
        
        @Test(arguments: [
            "geo:",
            "geo:48.2010",
            "geo:48.2010,",
            "geo:48.2010,abc",
            "geo:48.2010, 16.3695",
            "geo:48.2010;16.3695"
        ]) func malformedCoordinate(arg: String) {
            #expect(throws: GeoURIError.malformed) {
                _ = try GeoURI(string: arg)
            }
        }
    }
    
    @Suite struct LatitudeParsing {
        @Test(arguments: [
            "geo:48.2010,16.3695",
            "geo:-48.2010,-16.3695",
            "geo:90.0,180",
            "geo:-90.0,-180",
        ]) func validLatitude(arg: String) {
            #expect(throws: Never.self) {
                _ = try GeoURI(string: arg)
            }
        }
        
        @Test(arguments: [
            "geo:90.01,16.3695",
            "geo:-90.01,16.3695"
        ]) func invalidLatitude(arg: String) {
            #expect(throws: GeoURIError.invalidLatitude) {
                _ = try GeoURI(string: arg)
            }
        }
    }
    
    @Suite struct LongitudeParsing {
        @Test(arguments: [
            "geo:48.2010,16.3695",
            "geo:48.2010,-16.3695",
            "geo:90.0,180",
            "geo:-90.0,-180",
        ]) func validLongitude(arg: String) {
            #expect(throws: Never.self) {
                _ = try GeoURI(string: arg)
            }
        }
        
        @Test(arguments: [
            "geo:48.2010,180.01",
            "geo:48.2010,-180.01"
        ]) func invalidLongitude(arg: String) {
            #expect(throws: GeoURIError.invalidLongitude) {
                _ = try GeoURI(string: arg)
            }
        }
    }
    
    @Suite struct AltitudeParsing {
        @Test(arguments: [
            "geo:48.2010,16.3695,123",
            "geo:48.2010,16.3695,-123",
            "geo:48.2010,16.3695,0",
            "geo:48.2010,16.3695,1.23",
            "geo:48.2010,16.3695,-1.23"
        ]) func validAltitude(arg: String) throws {
            let geoURI = try GeoURI(string: arg)
            #expect(geoURI.altitude != nil)
        }
        
        @Test(arguments: [
            "geo:48.2010,16.3695",
            "geo:48.2010,16.3695,high"
        ]) func nilAltitude(arg: String) throws {
            let geoURI = try GeoURI(string: arg)
            #expect(geoURI.altitude == nil)
        }
    }
    
    @Suite struct CRSParsing {
        @Test(arguments: [
            "geo:48.2010,16.3695;crs=wgs84",
            "geo:48.2010,16.3695;crs=WGS84",
            "geo:48.2010,16.3695;crs"
        ]) func validCrs(arg: String) throws {
            let geoURI = try GeoURI(string: arg)
            #expect(geoURI.crs == .wgs84)
        }
        
        @Test(arguments: [
            "geo:48.2010,16.3695;crs=wgs84 ",
            "geo:48.2010,16.3695;crs=",
            "geo:48.2010,16.3695;crs= wgs84"
        ]) func malformedCRS(arg: String) {
            #expect(throws: GeoURIError.malformed) {
                _ = try GeoURI(string: arg)
            }
        }
        
        @Test func unsupportedCRS() {
            #expect {
                try GeoURI(string: "geo:48.2010,16.3695;crs=nad27")
            } throws: { error in
                guard let parsingError = error as? GeoURIError,
                      case let .unsupportedCoordinateReferenceSystem(crs) = parsingError
                else {
                    return false
                }
                return crs == "nad27"
            }
        }
    }
    
    @Suite struct UncertaintyParsing {
        @Test(arguments: [
            "geo:48.2010,16.3695;u=123.4",
            "geo:48.2010,16.3695;u=0",
            "geo:48.2010,16.3695;u=123;u=666"
        ]) func validUncertainty(arg: String) throws {
            let geoURI = try GeoURI(string: arg)
            #expect(geoURI.uncertainty != nil)
        }
        
        @Test(arguments: [
            "geo:48.2010,16.3695;u=-0.01",
            "geo:48.2010,16.3695;u=-123",
        ]) func invalidUncertainty(arg: String) throws {
            #expect(throws: GeoURIError.invalidUncertainty) {
                _ = try GeoURI(string: arg)
            }
        }
        
        @Test(arguments: [
            "geo:48.2010,16.3695;u=very",
            "geo:48.2010,16.3695;u"
        ]) func nilUncertainty(arg: String) throws {
            let geoURI = try GeoURI(string: arg)
            #expect(geoURI.uncertainty == nil)
        }
        
        @Test(arguments: [
            "geo:48.2010,16.3695;u=",
            "geo:48.2010,16.3695;u=666 "
        ]) func malformedUncertainty(arg: String) throws {
            #expect(throws: GeoURIError.malformed) {
                _ = try GeoURI(string: arg)
            }
        }
    }

}
