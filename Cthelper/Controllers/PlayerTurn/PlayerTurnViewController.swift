import UIKit
import RxSwift
import RxCocoa

public class PlayerTurnViewController: UIViewController {
    @IBOutlet public weak var childContainer: UIView!
    @IBOutlet public weak var sanityControl: UISegmentedControl!
    @IBOutlet private weak var playerLabel: UILabel!
    @IBOutlet private weak var summoningRateControl: UISegmentedControl!
    
    public var player: Player? {
        didSet { updatePlayerDisplay() }
    }
    
    public var summoningRate: BehaviorRelay<SummoningRate>?
    
    public var sanity: Observable<Sanity> { return _sanity }
    private var _sanity = PublishSubject<Sanity>()
    
    private let bag = DisposeBag()
    
    public init(player: Player?, summoningRate: Int) {
        super.init(nibName: nil, bundle: nil)
        self.player = player
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24.0, weight: .black)]
        sanityControl.setTitleTextAttributes(attrs, for: .normal)
        summoningRateControl.setTitleTextAttributes(attrs, for: .normal)
        updatePlayerDisplay()
        
        sanityControl.rx.selectedSegmentIndex
            .map { $0 == 0 ? .sane : .insane }
            .bind(to: _sanity)
            .disposed(by: bag)

        bindToSummoningRate()
    }
    
    private func bindToSummoningRate() {
        guard let summoningRate = summoningRate else { return }
        
        summoningRate.asObservable()
            .map { $0 == .two ? 0 : 1 }
            .bind(to: summoningRateControl.rx.selectedSegmentIndex)
            .disposed(by: bag)
        summoningRateControl.rx.selectedSegmentIndex
            .map { $0 == 0 ? .two : .three }
            .bind(to: summoningRate)
            .disposed(by: bag)
    }

    private func updatePlayerDisplay() {
        guard view != nil else { return }
        guard let player = player else {
            playerLabel.text = ""
            playerLabel.isHidden = true
            sanityControl.isHidden = true
            return
        }
        playerLabel.text = "\(player.name) • \(player.role)"
        sanityControl.selectedSegmentIndex = (player.isSane ? 0 : 1)
        playerLabel.isHidden = false
        sanityControl.isHidden = false
    }
    
    private func updateSummoningDisplay() {
        
    }
}
