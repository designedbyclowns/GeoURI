# ``GeoURI``


A Swift implementation of the geo URI scheme.

## Overview

The geo URI scheme is a Uniform Resource Identifier (URI) scheme defined by the Internet Engineering Task Force's [RFC 5870](https://datatracker.ietf.org/doc/html/rfc5870).

A 'geo' URI identifies a physical location in a two- or three-dimensional
coordinate reference system in a compact, simple, human-readable, and
protocol-independent way.

### Coordinate Reference System

The values of the coordinates only make sense when a coordinate reference system (CRS) is specified. The default coordinate reference system used is the [World Geodetic System 1984](https://earth-info.nga.mil/?dir=wgs84&action=wgs84) (WGS-84). 

## Examples

A simple geo URI:

```
geo:13.4125,103.8667
```

### Latitude & Longitude

Latitude and longitude are represent by two numerical values, and are separated by a comma. They are coordinates of a horizontal grid (2D). 

Coordinates in the Southern and Western hemispheres are signed negative with a leading dash.

```
geo:-48.876667,-123.393333
```

_Point Nemo – also know as "the oceanic pole of inaccessibility" and is the place in the ocean that is farthest from land at latitude -48.876667 (48° 52′ 36″ S), and longitude -123.393333 (123° 23′ 36″ W)._


### Altitude

If a third comma-separated value is present, it represents altitude; so, coordinates of a 3D grid. 

Altitudes below the coordinate reference system (depths) are signed negative with a leading dash.

```
geo:27.988056,86.925278,8848.86
```

_Mount Everest – with an altitude of 8,848.86 m (29,031.7 ft) is earth's highest mountain above sea level, located in the Mahalangur Himal sub-range of the Himalayas._

### Uncertainty

The geo URI specification also allows for an optional "uncertainty" value, separated by a semicolon, representing the uncertainty of the location in meters, and is described using the "u" URI parameter.

```
geo:11.373333,142.591667,-10920?u=10
```

_Challenger Deep – the deepest known point of the seabed of Earth, located in the western Pacific Ocean at the southern end of the Mariana Trench with an uncertainty of ± 10 meters._

## Topics

### Structures

- ``GeoURI``

### Errors

- ``GeoURIError``
- ``GeoURIParsingError``

### Formatting

- ``GeoURI/FormatStyle``
- ``GeoURI/ParseStrategy``
