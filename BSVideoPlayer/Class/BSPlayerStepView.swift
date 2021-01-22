//
//  BSPlayerStepView.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/9/30.
//

import Foundation
import UIKit

public class BSPlayerStepView: UIView {
	
	var value: Float = 0
	var currentTime: Int = 0 {
		didSet {
			progress.progress = Float(currentTime)/Float(duration)
			contentLabel.text = currentTime.transToHMS()
			let w = contentLabel.text!.s_getTextWidth(fontSize: 28, h: 30) + 3
			if w + 20 > s_width {
				s_width = w + 20
				layoutIfNeeded()
			}
		}
	}
	var duration: Int = 0
	
	private var contentLabel: UILabel
	private var progress: UIProgressView
	
	override init(frame: CGRect) {
		contentLabel = UILabel.init(frame: CGRect.zero)
		progress = UIProgressView.init(frame: CGRect.zero)
		super.init(frame: frame)
		backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
		layer.cornerRadius = 4
		
		contentLabel.font = UIFont.systemFont(ofSize: 28)
		contentLabel.textColor = UIColor.white
		contentLabel.textAlignment = .center
		addSubview(contentLabel)
		
		progress.trackTintColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.3)
		progress.progressTintColor = UIColor.lightGray
		addSubview(progress)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		var x: CGFloat = 0
		var y: CGFloat = 8
		var w: CGFloat = s_width
		var h: CGFloat = 30
		contentLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = 20
		h = 2
		w = s_width - x*2
		y = contentLabel.s_top + contentLabel.s_height + 8
		progress.frame = CGRect.init(x: x, y: y, width: w, height: h)
	}
	
}
