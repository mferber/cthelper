import UIKit
import RxCocoa
import RxSwift

public class AddPlayersViewController: UIViewController {
    
    /// Reports the full player list when the user indicates they're ready to begin the game.
    public var players: Observable<[Player]> { return _players }
    private let _players = PublishSubject<[Player]>()

    /// Tracks the player list internally as it's being built.
    private var playersInProgress = BehaviorRelay<[Player]>(value: [])

    @IBOutlet private weak var detectiveButton: UIButton!
    @IBOutlet private weak var doctorButton: UIButton!
    @IBOutlet private weak var driverButton: UIButton!
    @IBOutlet private weak var hunterButton: UIButton!
    @IBOutlet private weak var magicianButton: UIButton!
    @IBOutlet private weak var occultistButton: UIButton!
    @IBOutlet private weak var reporterButton: UIButton!
    @IBOutlet private weak var playerList: UILabel!
    @IBOutlet private weak var beginGameButton: UIButton!
    
    private var roleMapping: [UIButton: Investigator]!
    private let bag = DisposeBag()
    
    override public func viewDidLoad() {
        roleMapping = [
            detectiveButton: .detective,
            doctorButton: .doctor,
            driverButton: .driver,
            hunterButton: .hunter,
            magicianButton: .magician,
            occultistButton: .occultist,
            reporterButton: .reporter
        ]
        
        roleMapping.keys.forEach { button in
            button.rx.tap.subscribe(onNext: { [weak self] _ in
                self?.addPlayer(for: button)
            }).disposed(by: bag)
        }
        
        playersInProgress.map { pp in
            pp.map { "\($0.name) • \($0.role)" }.joined(separator: "\n") }
                .bind(to: playerList.rx.text)
                .disposed(by: bag)
        
        beginGameButton.rx.tap.asObservable().withLatestFrom(playersInProgress)
            .bind { [weak self] finalList in self?._players.onNext(finalList)
            }.disposed(by: bag)
    }
    
    private func addPlayer(for tappedButton: UIButton?) {
        guard let tappedButton = tappedButton, let role = roleMapping[tappedButton] else { return }
        
        let alert = UIAlertController(title: "Add \(role)", message: "Please enter the player's name:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            if let name = alert.textFields?[0].text {
                self?.recordPlayer(name: name, role: role)
                tappedButton.isEnabled = false
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func recordPlayer(name: String, role: Investigator) {
        var updatedPlayers = playersInProgress.value
        updatedPlayers.append(Player(name: name, role: role))
        self.playersInProgress.accept(updatedPlayers)
        
    }
}
