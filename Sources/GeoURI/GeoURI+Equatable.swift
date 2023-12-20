/**
 https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.4
 */
extension GeoURI: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.altitude == rhs.altitude &&
        lhs.crs == rhs.crs &&
        lhs.uncertainty == rhs.uncertainty
    }
}
