# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Project

Swift package implementing the `geo:` URI scheme defined by [RFC 5870](https://datatracker.ietf.org/doc/html/rfc5870). The RFC is the canonical reference — when in doubt about validation rules, normalization, or equality semantics, defer to it (and to the section links already cited in the source).

`Package.swift` is the source of truth for tools/platforms: `swift-tools-version: 6.0`, platforms `macOS .v13 / iOS .v16 / tvOS .v16 / watchOS .v9`. (The README's "macOS 10.13" line is a typo — do not propagate it.)

## Commands

```bash
swift build                                 # build the library
swift test                                  # run all tests
swift test --filter GeoURITests.LatitudeBounds  # run a single suite (dot path: TypeName.NestedSuite)
swift test --filter initWithString          # run a single @Test by name
swift package generate-documentation        # build the DocC catalog (Sources/GeoURI/GeoURI.docc)
```

CI (`.github/workflows/tests.yml`) runs `swift build` + `swift test` on `macos-latest` via `SwiftyLab/setup-swift`.

## Architecture

Single public type `GeoURI` (a `Sendable` struct), with capabilities split across extension files. New behavior should follow that file layout rather than piling onto `GeoURI.swift`:

- `GeoURI.swift` — stored properties, designated `init(latitude:longitude:altitude:uncertainty:)`, and `init(string:)` which parses with a `RegexBuilder` regex. This is where validation and **RFC normalization** live (see below).
- `GeoURI+URL.swift` — `init(url:)` and the `url` computed property. Parses via `URLComponents`; query items other than `crs` and `u` are ignored. Throws `GeoURIParsingError` (wraps a `GeoURIError` with the offending URL).
- `GeoURI+CoreLocation.swift` — bridges to `CLLocation` / `CLLocationCoordinate2D`. Wrapped in `#if canImport(CoreLocation)` so Linux builds keep working.
- `FormatStyle.swift` — `GeoURI.FormatStyle: Foundation.FormatStyle` plus `.short` / `.full` static accessors and a shared `numberStyle` (8 fraction digits ≈ 1.1mm at the equator, no grouping).
- `ParseStrategy.swift` — `GeoURI.ParseStrategy: Foundation.ParseStrategy`; `FormatStyle` conforms to `ParseableFormatStyle` so `GeoURI(_:format:)` round-trips with `formatted(_:)`.
- `GeoURI+Equatable.swift` — equality compares all five fields per [§3.4.4](https://datatracker.ietf.org/doc/html/rfc5870#section-3.4.4); zero uncertainty and `nil` uncertainty are intentionally **not** equal.
- `GeoURIError.swift` / `GeoURIParsingError.swift` — typed throws (`throws(GeoURIError)`) for direct construction; `init(url:)` wraps into `GeoURIParsingError` so callers get the URL alongside the cause.

### RFC normalization that is easy to break

Both rules are enforced inside the designated initializer in `GeoURI.swift` — keep them there:

- At the poles (`latitude == ±90`), `longitude` is forced to `0`.
- `longitude == -180` is normalized to `180` (date-line case).

If you add new construction paths, route them through the designated initializer rather than re-implementing these rules.

### Errors

Initializers use Swift 6 typed throws: `throws(GeoURIError)` for value-level construction, `throws(GeoURIParsingError)` for `init(url:)`. Preserve these signatures — callers rely on the concrete error type. `GeoURIParsingError` always carries the original `URL`; do not collapse it to a plain `GeoURIError` when surfacing parse failures from a URL.

## Tests

Uses **Swift Testing** (`import Testing`, `@Test`, `@Suite`, `#expect`, `#expect(throws:)`), not XCTest. Group related cases under nested `@Suite struct` types (e.g. `LatitudeBounds`, `LongitudeBounds`) and prefer parameterized `@Test(arguments: [...])` for boundary tables — the existing tests show the convention. When adding tests for a new RFC rule, cite the section in a doc comment the way `GeoURITests.swift` already does.
