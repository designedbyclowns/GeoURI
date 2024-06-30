import Testing
import Foundation
@testable import GeoURI

struct GeoURI_EquateableTests {
    
    @Test func latitudeEquality() throws {
        let a = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        var b = a
        #expect(a == b)
        
        b = try GeoURI(latitude: 48.20101, longitude: 16.3695)
        #expect(a != b)
    }
    
    @Test func longitudeEquality() throws {
        let a = try GeoURI(latitude: 48.2010, longitude: 16.3695)
        var b = a
        #expect(a == b)
        
        b = try GeoURI(latitude: 48.20101, longitude: 16.36951)
        #expect(a != b)
    }
    
    @Test func altitudeEquality() throws {
        let a = try GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
        var b = a
        #expect(a == b)
        
        b = try GeoURI(latitude: 48.2010, longitude: 16.36951)
        #expect(a != b)
        
        let c = try GeoURI(latitude: 48.2010, longitude: 16.36951, altitude: 0)
        #expect(b != c)
        
        b = try GeoURI(latitude: 48.2010, longitude: 16.36951, altitude: 1830.01)
        #expect(a != b)
    }
    
    @Test func uncertaintyEquality() throws {
        let a = try GeoURI(latitude: 48.2010, longitude: 16.3695, uncertainty: 1.0)
        var b = a
        #expect(a == b)
        
        b = try GeoURI(latitude: 48.2010, longitude: 16.36951)
        #expect(a != b)
        
        let c = try GeoURI(latitude: 48.2010, longitude: 16.36951, uncertainty: 0)
        #expect(b != c)
        
        b = try GeoURI(latitude: 48.2010, longitude: 16.36951, uncertainty: 1.01)
        #expect(a != b)
    }
}

