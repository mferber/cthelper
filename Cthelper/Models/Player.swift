import Foundation
import RxSwift
import RxCocoa

public class Player {
    public let name: String
    public let role: Investigator
    public let sanity = BehaviorRelay<Sanity>(value: .sane)
    public var isSane: Bool { return sanity.value == .sane }
    
    public init(name: String, role: Investigator) {
        self.name = name
        self.role = role
    }
}

extension Player: CustomStringConvertible {
    public var description: String {
        return "\(self.name)<\(isSane ? "" : "insane ")\(role)>"
    }
}
