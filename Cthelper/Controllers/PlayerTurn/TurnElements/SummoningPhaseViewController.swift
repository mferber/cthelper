import UIKit
import RxCocoa
import RxSwift

class SummoningPhaseViewController: UIViewController {
    @IBOutlet private var counterView: CounterView!
    
    public var finished: Observable<Void> { return _finished }
    private let _finished = PublishSubject<Void>()
    
    public var summoningRate: Observable<SummoningRate>?
    
    private let bag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.rx.event.bind { [weak self] _ in
            self?.counterView.advance()
            }.disposed(by: bag)
        
        summoningRate?.subscribe(onNext: { [weak self] rate in
            self?.counterView.length = rate.asInt
        }).disposed(by: bag)

        
        
        counterView.finished.bind { [weak self] _ in
            self?._finished.onNext(())
        }.disposed(by: bag)
    }
}

