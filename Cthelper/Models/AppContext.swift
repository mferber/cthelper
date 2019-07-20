import RxCocoa

public struct AppContext {
    public var players = BehaviorRelay<[Player]>(value: [])
    public var summoningRate = BehaviorRelay<SummoningRate>(value: .two)
    
    public init() { }
    
    public func updatePlayers(_ newPlayers: [Player]) {
        players.accept(newPlayers)
    }
}
