//
//  InputView.swift
//  
//
//  Created by Shawn Ma on 12/4/18.
//

import Foundation
import UIKit
import SnapKit

class InputView: UIView {
    
    let dissmissButton: UIButton = {
        let button = UIButton()
        let img = UIImage(named: "dismiss")
        button.setImage(img, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }()
    
    let bobInput: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Talk to Bob!"
        textField.textColor = .white
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        textField.layer.cornerRadius = 6.0
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 30)
        return textField
    }()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: .zero)
        
        self.addSubview(dissmissButton)
        self.addSubview(bobInput)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView() {
        self.backgroundColor = .clear
        self.snp.makeConstraints { (make) in
            make.edges.equalTo(self).offset(0)
        }
        
        dissmissButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.left.equalTo(self).offset(15)
            make.top.equalTo(self.safeAreaInsets.top).offset(40)
        }
        
        bobInput.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(200)
            make.height.equalTo(60)
            make.right.equalToSuperview().offset(-30)
        }
    }
    
}
