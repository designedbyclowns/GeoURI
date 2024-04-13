extension GeoURI: Equatable {
    public static func == (lhs: GeoURI, rhs: GeoURI) -> Bool {
        // See https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.4
        return lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.altitude == rhs.altitude &&
        lhs.crs == rhs.crs &&
        lhs.uncertainty == rhs.uncertainty
    }
}
