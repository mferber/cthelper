import UIKit
import RxCocoa
import RxSwift

public class CounterView: UIView {
    public var finished: Observable<Void> { return _finished }
    private let _finished = PublishSubject<Void>()
    
    @IBInspectable public var length: Int = 0 {
        didSet {
            if length < 0 { length = 0 }
            rebuildSubviews()
        }
    }
    @IBInspectable private var selectedColor: UIColor = .white {
        didSet {
            self.subviews.forEach { ($0 as? NumberedCircleView)?.selectedColor = selectedColor }
        }
    }
    
    private var selectedIndex: Int = 0
    private var tap = UITapGestureRecognizer()
    private let bag = DisposeBag()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.advance()
        }).disposed(by: bag)
    }
    
    private func rebuildSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
        guard length > 0 else { return }
        
        for i in 1...length {
            let circle = NumberedCircleView(frame: .zero, selectedColor: selectedColor, number: Int(i))
            let prevCircle = self.subviews.last
            self.addSubview(circle)
            
            circle.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            if let prevCircle = prevCircle {
                circle.leftAnchor.constraint(equalTo: prevCircle.rightAnchor, constant: 10).isActive = true
            } else {
                circle.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            }
            if i == length {
                circle.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            }
            
            (subviews.first as? NumberedCircleView)?.selected = true
            selectedIndex = 0
        }
    }
    
    public func advance() {
        guard selectedIndex + 1 < length else { _finished.onNext(()); return }
        selectedIndex += 1
        for idx in 0..<length {
            (subviews[Int(idx)] as? NumberedCircleView)?.selected = (idx == selectedIndex)
        }
    }
}
