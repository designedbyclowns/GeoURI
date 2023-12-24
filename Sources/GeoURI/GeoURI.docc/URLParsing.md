# Parsing URL's

## Creating a GeoURI from a URL

A GeoURI can be created from a URL that conforms to the geo URI scheme.

- ``GeoURI/init(url:)``

The URL must adhere to the [rfc5870](https://datatracker.ietf.org/doc/html/rfc5870) specification – the basics of which are summarized here.

A ``GeoURI/GeoURIParsingError`` will be thrown if the provided URL does not meet the expected criteria.

### Scheme

- The scheme scheme subcomponent of the URL must be the string "geo".

### Path

- The path subcomponent of the URL must consist of 2 to 3 numeric values representing ``GeoURI/latitude``, ``GeoURI/longitude``, and optionally ``GeoURI/altitude``, respectively.
- Latitude value outside the range of -90 to 90 degrees are considered invalid.
- Longitude value outside the range of -180 to 180 degrees are considered invalid.
- The ``GeoURI/longitude`` of coordinate values reflecting the poles (``GeoURI/latitude`` values of -90 or 90 degrees) will be set to 0 since all longitude values are equal at the poles.
- A ``GeoURI/longitude`` of -180 degrees will be set to 180 as both represent the international dateline and must be considered equal.
- The ``GeoURI/altitude`` component is optional. If provided, the value is interpreted to be relative to a surface defined by Earth's gravity approximating the mean sea level.

> Note: When altitude is not provided, the elevation is assumed to be the altitude of the latitude-longitude point, that is its height (or negative depth) relative to the geoid (i.e. "ground elevation"). A value of 0 is, however, not to be confused with an undefined value: it refers to an altitude of 0 meters above the geoid.

### Query Parameters

The geo URI specification allows for two query parameters; Uncertainty (u) and Coordinate Reference System (crs) in the query subcomponent of the URL. Both of which are optional.

If a parameter is provided, it must only be provided once. The names and values of query parameters are case-insensitive.

Additional query parameters are ignored.

#### coordinate reference system (crs)

The Coordinate Reference System (CRS) used to interpret coordinate values.

```
geo:-48.876667,-123.393333;crs=wgs84
```

Currently the only supported CRS is the [World Geodetic System 1984](https://earth-info.nga.mil/?dir=wgs84&action=wgs84) (WGS-84), the value for which is "wgs84". 

If not provided, WGS-84 is assumed. See [rfc5870#section-3.4.1](https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.1).

#### Uncertainty (u)

The ``GeoURI/uncertainty`` parameter represents the "uncertainty" of the location in meters, and is described using the "u" URI parameter.

```
geo:11.373333,142.591667,-10920;u=10
```

If present, its value must be greater than or equal to zero. When not provided, the the uncertainty is assumed to be unknown.

If the intent is to indicate a specific point in space, the value _may_ be set to zero. The value applies to all dimensions of the location.

> Tip: Zero uncertainty and absent uncertainty are never the same thing. See [rfc5870#section-3.4.3](https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.3).
