import UIKit
import RxCocoa
import RxSwift

public class ActionsPhaseViewController: UIViewController {
    private static let baseActionCount = 4
    
    @IBOutlet private var counterView: CounterView!
    @IBOutlet private var alienCarvingButton: UIButton!
    
    public var role: Investigator?
    public var sanity: Observable<Sanity>!
    
    public var finished: Observable<Void> { return _finished }
    private let _finished = PublishSubject<Void>()
    
    private let bag = DisposeBag()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.rx.event.bind { [weak self] _ in
            self?.counterView.advance()
        }.disposed(by: bag)
        
        sanity.subscribe(onNext: { [weak self] sanityState in
            var actionCount: Int = ActionsPhaseViewController.baseActionCount
            if self?.role == .doctor { actionCount += 1 }
            if sanityState == .insane { actionCount -= 1 }
            self?.counterView.length = actionCount
        }).disposed(by: bag)
        
        alienCarvingButton.rx.tap.bind { [weak self] in
            self?.add3Actions()
        }.disposed(by: bag)
        
        counterView.finished.bind { [weak self] _ in
            self?._finished.onNext(())
        }.disposed(by: bag)
    }

    private func add3Actions() {
        counterView.length += 3
        alienCarvingButton.isEnabled = false
    }    
}

