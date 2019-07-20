import Foundation

public enum Investigator: String {
    case hunter = "Hunter"
    case reporter = "Reporter"
    case magician = "Magician"
    case doctor = "Doctor"
    case driver = "Driver"
    case occultist = "Occultist"
    case detective = "Detective"
}

extension Investigator: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}
