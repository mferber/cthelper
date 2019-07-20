import UIKit
import RxCocoa
import RxSwift

class PlayerTurnCoordinator {
    private enum Phase {
        case none
        case actions(controller: ActionsPhaseViewController)
        case drawCards(controller: UIViewController)
        case summoning(controller: SummoningPhaseViewController)
    }
    
    public var controller: UIViewController! {
        return turnController
    }
    
    public var finished: Observable<Void> { return _finished }
    private let _finished = PublishSubject<Void>()

    private let storyboard: UIStoryboard
    private let turnController: PlayerTurnViewController!
    private var activePhaseController: UIViewController?  // retains
    
    private let player: Player
    private var phase: Phase = .none

    private let bag = DisposeBag()
    
    public init(storyboard: UIStoryboard, player: Player, summoningRate: BehaviorRelay<SummoningRate>) {
        self.storyboard = storyboard
        self.player = player

        self.turnController = storyboard.instantiateViewController(withIdentifier: StoryboardIds.playerTurn)
            as? PlayerTurnViewController
        self.turnController.summoningRate = summoningRate
        
        self.turnController.rx.viewDidLoad.bind { [weak self] in
            self?.beginActionsPhase()
        }.disposed(by: bag)
        
        self.turnController.sanity
            .bind(to: player.sanity)
            .disposed(by: bag)

        self.turnController.player = player
    }
    
    private func beginActionsPhase() {
        guard let actionsController = storyboard.instantiateViewController(withIdentifier: StoryboardIds.actions)
            as? ActionsPhaseViewController else { return }
        
        activePhaseController = actionsController
        
        actionsController.role = turnController.player?.role
        actionsController.sanity = turnController.player?.sanity.asObservable()
        actionsController.view.translatesAutoresizingMaskIntoConstraints = false
        
        turnController.mafAdopt(actionsController, asSubviewOf: turnController.childContainer)
        phase = .actions(controller: actionsController)
        
        actionsController.finished.subscribe(onNext: { [weak self] in
            self?.beginDrawCardsPhase()
        }).disposed(by: bag)
    }
    
    private func beginDrawCardsPhase() {
        guard
            case let .actions(controller: actionsController) = phase,
            let drawCardsController = storyboard.instantiateViewController(withIdentifier: StoryboardIds.drawCards)
                as? DrawCardsPhaseViewController
            else { return }
        
        drawCardsController.view.translatesAutoresizingMaskIntoConstraints = false
        
        turnController.mafDisown(actionsController)
        turnController.mafAdopt(drawCardsController, asSubviewOf: turnController.childContainer)
        phase = .drawCards(controller: drawCardsController)
        
        drawCardsController.finished.subscribe(onNext: { [weak self] in
            self?.beginSummoningPhase()
        }).disposed(by: bag)
    }
    
    private func beginSummoningPhase() {
        guard
            case let .drawCards(controller: drawCardsController) = phase,
            let summoningController = storyboard.instantiateViewController(withIdentifier: StoryboardIds.summoning)
                as? SummoningPhaseViewController
            else { return }

        summoningController.summoningRate = self.turnController.summoningRate?.asObservable()
        summoningController.view.translatesAutoresizingMaskIntoConstraints = false
        
        turnController.mafDisown(drawCardsController)
        turnController.mafAdopt(summoningController, asSubviewOf: turnController.childContainer)
        phase = .summoning(controller: summoningController)
        
        summoningController.finished.subscribe(onNext: { [weak self] in
            self?._finished.onNext(())
        }).disposed(by: bag)
    }
}
