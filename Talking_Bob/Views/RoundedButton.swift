/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom button that stands out over the camera view in the scanning UI.
*/

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor(named: "appBlue")
        layer.cornerRadius = 8
        clipsToBounds = true
        setTitleColor(.white, for: [])
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? UIColor(named: "appBlue") : UIColor(named: "appGray")
        }
    }
    
    var toggledOn: Bool = true {
        didSet {
            if !isEnabled {
                backgroundColor = UIColor(named: "appGray")
                return
            }
            backgroundColor = toggledOn ? UIColor(named: "appBlue") : UIColor(named: "appLightBlue")
        }
    }
}
