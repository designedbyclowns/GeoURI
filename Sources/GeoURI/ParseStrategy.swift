import Foundation

extension GeoURI {
    /// A `ParseStrategy` that converts a formatted string into a ``GeoURI``.
    ///
    /// Usage:
    ///
    ///  ```swift
    ///  let geoURI = try GeoURI.ParseStrategy.parse("geo:48.201,16.3695")
    ///  ```
    ///
    /// _or_
    ///
    ///  ```swift
    ///  let geoURI = try GeoURI("geo:48.201,16.3695", format: GeoURI.FormatStyle)
    ///  ```
    public struct ParseStrategy: Foundation.ParseStrategy {
        // The input type parsed by this strategy.
        public typealias ParseInput = String
        /// The output type returned by this strategy.
        public typealias ParseOutput = GeoURI
        
        /// Parses a string into a ``GeoURI``, using this strategy.
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

extension GeoURI {
    /// Creates and initializes a ``GeoURI`` by parsing a string according to the provided format style.
    public init<F: ParseableFormatStyle>(
        _ value: String,
        format: F
    ) throws where F.FormatInput == Self, F.FormatOutput == String {
        self = try format.parseStrategy.parse(value)
    }
}
