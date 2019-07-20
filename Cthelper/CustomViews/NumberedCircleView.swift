import UIKit

public class NumberedCircleView: UIView {

    private enum Constants {
        static let deselectedColor = UIColor(white: 0.8, alpha: 1.0)
    }

    @IBInspectable public var selectedColor: UIColor = .clear
    @IBInspectable public var number: Int = 0 {
        didSet {
            updateLabel()
        }
    }
    @IBInspectable public var selected = false {
        didSet {
            setNeedsDisplay()
        }
    }

    private let font: UIFont = .systemFont(ofSize: 24.0, weight: .black)
    private let label = UILabel()

    public init(frame: CGRect, selectedColor: UIColor, number: Int) {
        self.selectedColor = selectedColor
        self.number = number

        label.text = String(number)
        super.init(frame: frame)
        initializeNumberedCircleView()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeNumberedCircleView()
    }

    private func initializeNumberedCircleView() {
        backgroundColor = .clear
        
        label.font = font
        updateLabel()
        addSubview(label)

        centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    private func updateLabel() {
        label.text = String(number)
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let cgContext = UIGraphicsGetCurrentContext() else { return }

        cgContext.setFillColor((selected ? selectedColor : Constants.deselectedColor).cgColor)
        cgContext.fillEllipse(in: bounds)
    }

}
