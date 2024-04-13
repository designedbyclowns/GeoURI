import Foundation
import RegexBuilder

public final class GeoURIFormatter: Formatter {
    
    // MARK: - Formatter

    override public func string(for obj: Any?) -> String? {
        guard let geoURI = obj as? GeoURI else { return nil }
        return geoURI.description
    }
    
    override public func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        do {
            obj?.pointee = try GeoURI(string: string)
            return obj?.pointee != nil
        } catch let err {
            error?.pointee = err.localizedDescription as NSString
            return false
        }
    }
}
