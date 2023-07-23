//
//  AnnulusView.swift
//  Squat Counter
//
//  Created by sam hastings on 15/07/2023.
//

import UIKit

class AnnulusView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
//    override func layoutSubviews() {
//            super.layoutSubviews()
//            setNeedsDisplay()
//    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Create outer (opaque) circle
        context.addEllipse(in: rect)
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fillPath()
        
        // Create inner (transparent) circle
        let innerRect = rect.insetBy(dx: rect.width * 0.1, dy: rect.height * 0.1)
        context.addEllipse(in: innerRect)
        context.setBlendMode(.clear)
        context.fillPath()
    }
}
