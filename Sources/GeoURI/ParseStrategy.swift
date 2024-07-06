import Foundation

extension GeoURI {
    public struct ParseStrategy: Foundation.ParseStrategy {
        public typealias ParseInput = String
        public typealias ParseOutput = GeoURI
        
        public func parse(_ value: String) throws -> GeoURI {
            return try GeoURI(string: value.trimmingCharacters(in: .whitespaces))
        }
    }
}

extension GeoURI.FormatStyle: ParseableFormatStyle {
    public var parseStrategy: GeoURI.ParseStrategy {
        .init()
    }
}
