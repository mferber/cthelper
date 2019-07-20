import UIKit
import RxCocoa
import RxSwift

public class MainCoordinator {
    private let appContext: AppContext

    private var activeSubcoordinator: AnyObject?
    private var activeController: UIViewController!
    
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    private var rootController: UIViewController!
    private let bag = DisposeBag()
    
    private let summoningRate = BehaviorRelay<SummoningRate>(value: .two)
    
    public init(appContext: AppContext) {
        self.appContext = appContext
    }
    
    public func launch(in window: UIWindow) {
        rootController = UIViewController()
        window.rootViewController = rootController
        
        let addPlayersController = storyboard.instantiateViewController(withIdentifier: StoryboardIds.addPlayers)
            as! AddPlayersViewController
        rootController.mafAdopt(addPlayersController, asSubviewOf: rootController.view)
        activeController = addPlayersController
        
        addPlayersController.players.bind { [weak self] players in
            self?.appContext.updatePlayers(players)
            self?.beginGame()
        }.disposed(by: bag)
    }
    
    public func beginGame() {
        beginTurn(players: appContext.players.value, index: 0)
    }
    
    public func beginTurn(players: [Player], index: Int) {
        let turnCoordinator = PlayerTurnCoordinator(storyboard: storyboard, player: players[index], summoningRate: summoningRate)
        
        let oldController: UIViewController = activeController

        rootController.mafAdopt(turnCoordinator.controller)
        rootController.transition(from: oldController, to: turnCoordinator.controller, duration: 1.0, options: [], animations: nil, completion: nil)
        
        activeSubcoordinator = turnCoordinator // retain
        activeController = turnCoordinator.controller

        turnCoordinator.finished.subscribe(onNext: { [weak self] () -> Void in
            self?.beginTurn(players: players, index: (index + 1) % players.count)
        }).disposed(by: bag)  // TODO: [] MF - Fix disposal so it doesn't all go in the same bag
    }
}
