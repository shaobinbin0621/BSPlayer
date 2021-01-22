//
//  BSPlayerTopView.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/9/29.
//

import Foundation
import UIKit

public class BSPlayerTopView: UIView {
	
	private var backBtn: VExpandButton
	
	private var gradientLayer: CAGradientLayer
	
	var clickBackBlock: (() -> Void)?
	
	var isPortrait = true
	
	override init(frame: CGRect) {
		backBtn = VExpandButton.init(type: .custom)
		gradientLayer = CAGradientLayer.init()
		super.init(frame: frame)
		
		let tColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
		let mColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
		let bColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
		gradientLayer.colors = [tColor.cgColor,mColor.cgColor, bColor.cgColor]
		gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint.init(x: 0, y: 1.0)
		layer.addSublayer(gradientLayer)
		
		backBtn.setBackgroundImage(UIImage.init(named: "back"), for: .normal)
		backBtn.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
		addSubview(backBtn)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		if isPortrait {
			setPortrait()
		}
		else {
			setLandscape()
		}
	}
	
	func setPortrait() {
		var x: CGFloat = 10
		var y: CGFloat = 10
		var w: CGFloat = s_height - y*2
		var h: CGFloat = w
//		if !UIDevice.current.isXSeries() && isAvoidTheStatusBar {
//			y = y + UIApplication.shared.statusBarFrame.height
//		}
		backBtn.frame = CGRect.init(x: x, y: y, width: w, height: h)
		gradientLayer.opacity = 0
		gradientLayer.frame = layer.bounds
	}
	
	func setLandscape() {
		var x: CGFloat = 10
		var y: CGFloat = 10
		var w: CGFloat = s_height - y*2
		var h: CGFloat = w
		backBtn.frame = CGRect.init(x: x, y: y, width: w, height: h)
		gradientLayer.opacity = 1
		gradientLayer.frame = layer.bounds
	}

	@objc func clickBack() {
		self.clickBackBlock?()
	}
}
