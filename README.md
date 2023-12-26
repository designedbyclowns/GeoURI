# GeoURI

A Swift implementation of the geo URI scheme.

The geo URI scheme is a Uniform Resource Identifier (URI) scheme defined by the Internet Engineering Task Force's [RFC 5870](https://datatracker.ietf.org/doc/html/rfc5870).

A 'geo' URI identifies a physical location in a two- or three-dimensional
coordinate reference system in a compact, simple, human-readable, and
protocol-independent way.

## Requirements

iOS 12, macOS 10.13, tvOS 12, watchOS 4

## Installation

This package is available via [Swift Package Manager](https://www.swift.org/package-manager/).

To install it, simply add the repo URL to your project in the usual way, and `import GeoURI` where needed.


## Usage

A `GeoURI` type can be crated from its constituent components (latitude, longitude, and an optional altitude), or from a URL that conforms the [geo URI scheme](https://datatracker.ietf.org/doc/html/rfc5870).

There are also CoreLocation extension to initialize a `GeoURI` from a `CLLocation` or `CLLocationCoordinate2D`.

An error will be thrown if any of the properties do not meet the specification.

See the [documentation](#documentation) for a complete reference.


### Creating a GeoURI
```swift
import GeoURI


let geoURI = try? GeoURI(latitude: 48.2010, longitude: 16.3695, altitude: 183)
let urlString = geoURI?.url.absoluteString // "geo:48.201,16.3695,183?crs=wgs84"
```

### Create a GeoURI from a URL

```swift
import GeoURI

if let let url = URL(string: "geo:-48.876667,-123.393333") {
    let geoURI = try? GeoURI(url: url)
}
```

### CoreLocation

```swift
import CoreLocation
import GeoURI

let coordinate = CLLocationCoordinate2D(latitude: 48.2010, longitude: 16.3695)
let geoURI = try? GeoURI(coordinate: coordinate)
let urlString = geoURI?.url.absoluteString // "geo:48.2010,16.3695?crs=wgs84"
```

### Handling errors
```swift
import GeoURI

if let url = URL(string: "geo:-48.876667,-123.393333") {
	do {
		let geoURI = try GeoURI(url: url)
	} catch let parsingError as? GeoURIParsingError {
		print("A parsing error occurred: \(parsingError.errorDescription)")
	} catch {
		print("\(error)")
	}
}
```

## Documentation

Documentation of this package is provided via a [DocC](https://www.swift.org/documentation/docc/) documentation catalog.

The official specification of [RFC 5870](https://datatracker.ietf.org/doc/html/rfc5870) is the canonical reference for the GeoURI scheme.

### Building the documentation

To build the documentation from the command-line:

```
$ swift package generate-documentation
```

Add the `--help` flag to get a list of all supported arguments and options.

### Xcode

You can also build the documentation directly in [Xcode](https://developer.apple.com/xcode/) from the Product menu:

**Product > Build Documentation**

The documentation can then be viewed in the documentation viewer.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue on the GitHub repository.
                                                                                                                             
## License


GeoURI is available under the [Unlicense](https://unlicense.org). See the [LICENSE](https://github.com/designedbyclowns/GeoURI/blob/main/LICENSE) file for more info.

