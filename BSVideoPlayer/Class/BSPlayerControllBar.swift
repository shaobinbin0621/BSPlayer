//
//  BSPlayerControllBar.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/9/18.
//

import Foundation
import UIKit

public class BSPlayerControlBar: UIView {
	
	private var progressView: UIProgressView
	private var slider: VSlider
	private var playBtn: UIButton
	private var currentTimeLabel: UILabel
	private var totalTimeLabel: UILabel
	private var fullScreenBtn: UIButton
	private var gradientLayer: CAGradientLayer
	private var speedBtn: UIButton
	
	var isPortrait: Bool = true
	
	var duration: Int = 0 {
		didSet {
			totalTimeLabel.text = duration.transToHMS()
			setPortrait()
		}
	}
	
	var curremTime: Int = 0 {
		didSet {
			currentTimeLabel.text = curremTime.transToHMS()
		}
	}
	
	var bufferProgress: Float = 0 {
		didSet {
			progressView.progress = bufferProgress
		}
	}
	
	var playProgress: Float = 0 {
		didSet {
			slider.value = playProgress
		}
	}
	
	var isPlaying: Bool = false {
		didSet {
			playBtn.isSelected = isPlaying
		}
	}
	
	var speed = "倍速" {
		didSet {
			speedBtn.setTitle(speed, for: .normal)
		}
	}
	
	var fullScreenClick: ((_ isSelectedd: Bool) -> Void)?
	var playClick:((_ isSelected: Bool) -> Void)?
	var sliderValueChangedBl: ((_ value: Float) -> Void)?
	var sliderTouchBeganBl:((_ value: Float) -> Void)?
	var sliderTouchEndBl:((_ value: Float) -> Void)?
	var speedClick: (() -> Void)?
	
	override init(frame: CGRect) {
		progressView = UIProgressView.init()
		slider = VSlider.init()
		playBtn = UIButton.init(type: .custom)
		currentTimeLabel = UILabel.init()
		totalTimeLabel = UILabel.init()
		fullScreenBtn = UIButton.init(type: .custom)
		gradientLayer = CAGradientLayer.init()
		speedBtn = UIButton.init(type: .custom)
		super.init(frame: frame)
		
		let tColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
		let mColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
		let bColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
		gradientLayer.colors = [tColor.cgColor,mColor.cgColor, bColor.cgColor]
		gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint.init(x: 0, y: 1.0)
		layer.addSublayer(gradientLayer)
		
		playBtn.addTarget(self, action: #selector(clickPlay), for: .touchUpInside)
		playBtn.setImage(UIImage.init(named: "Play"), for: .normal)
		playBtn.setImage(UIImage.init(named: "Pause"), for: .selected)
		addSubview(playBtn)
		
		currentTimeLabel.textColor = UIColor.white
		currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
		currentTimeLabel.text = "00:00"
		addSubview(currentTimeLabel)
		
		progressView.progressTintColor = UIColor.lightGray
		progressView.trackTintColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
		addSubview(progressView)
		
		slider.minimumValue = 0.0
		slider.maximumValue = 1.0
		slider.minimumTrackTintColor = UIColor.orange
		slider.maximumTrackTintColor = UIColor.clear
		slider.setThumbImage(UIImage.init(named: "dot")?.s_scalingToSize(size: CGSize.init(width: 15, height: 15)), for: .normal)
		slider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
		slider.addTarget(self, action: #selector(sliderTouchBegan), for: .touchDown)
		slider.addTarget(self, action: #selector(sliderTouchEnd), for: .touchUpInside)
		slider.addTarget(self, action: #selector(sliderTouchEnd), for: .touchCancel)
		slider.addTarget(self, action: #selector(sliderTouchEnd), for: .touchUpOutside)
		addSubview(slider)
		
		totalTimeLabel.textColor = UIColor.white
		totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
		totalTimeLabel.text = "00:00"
		addSubview(totalTimeLabel)
		
		fullScreenBtn.addTarget(self, action: #selector(clickFullScreen), for: .touchUpInside)
		fullScreenBtn.setImage(UIImage.init(named: "full-screen_1"), for: .normal)
		addSubview(fullScreenBtn)
		
		speedBtn.setTitle(speed, for: .normal)
		speedBtn.setTitleColor(UIColor.white, for: .normal)
		speedBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		speedBtn.contentHorizontalAlignment = .center
		speedBtn.addTarget(self, action: #selector(clickSpeed), for: .touchUpInside)
		speedBtn.isHidden = true
//		speedBtn.layer.borderWidth = 2
//		speedBtn.layer.borderColor = UIColor.white.cgColor
		addSubview(speedBtn)
		
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
	
	func reset() {
		playBtn.isSelected = false
		slider.value = 0
		currentTimeLabel.text = "00:00"
	}
	
	//MARK: - Action
	@objc private func sliderValueChange() {
		self.sliderValueChangedBl?(slider.value)
	}
	
	@objc private func sliderTouchBegan() {
		self.sliderTouchBeganBl?(slider.value)
	}
	
	@objc private func sliderTouchEnd() {
		self.sliderTouchEndBl?(slider.value)
	}
	
	@objc private func clickPlay() {
		playClick?(playBtn.isSelected)
	}
	
	@objc private func clickFullScreen() {
		fullScreenClick?(fullScreenBtn.isSelected)
	}
	
	@objc private func clickSpeed() {
		speedClick?()
	}
	
	private func setPortrait() {
		var x: CGFloat = 10
		var y: CGFloat = 10
		var w: CGFloat = s_height - y*2
		var h: CGFloat = w
		playBtn.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = playBtn.s_right + 10
		w = (totalTimeLabel.text == nil ? "00:00" : totalTimeLabel.text)!.s_getTextWidth(fontSize: totalTimeLabel.font.pointSize, h: 20) + 3
		currentTimeLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		w = playBtn.s_width
		x = s_width - 10 - w
		fullScreenBtn.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		w = currentTimeLabel.s_width
		x = fullScreenBtn.s_left - 10 - w
		totalTimeLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = currentTimeLabel.s_right + 10
		y = s_height/2 - 1
		h = 2
		w = totalTimeLabel.s_left - currentTimeLabel.s_right - 10 * 2
		progressView.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = progressView.s_left - 3
		w = w + 6
		y = y + (progressView.s_height == 2 ? 0 : 1)
//		y = y + 1
		slider.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		gradientLayer.frame = layer.bounds
		
		fullScreenBtn.isHidden = false
		speedBtn.isHidden = true
	}
	
	private func setLandscape(){
		var x: CGFloat = 10
		var y: CGFloat = 10
		var w: CGFloat = (totalTimeLabel.text == nil ? "00:00" : totalTimeLabel.text)!.s_getTextWidth(fontSize: totalTimeLabel.font.pointSize, h: 20) + 3
		var h: CGFloat = 15
		currentTimeLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = s_width - 10 - w
		totalTimeLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = 0
		y = currentTimeLabel.s_top + currentTimeLabel.s_height + 10
		w = s_width
		h = 2
		progressView.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = x - 3
		w = w + 6
		y = y + (progressView.s_height == 2 ? 0 : 1)
		slider.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = currentTimeLabel.s_left
		y = currentTimeLabel.s_top + currentTimeLabel.s_height + 10 + 10 + 7.5
		w = 30
		h = 30
		playBtn.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		w = 45
		h = 30
		x = s_width - w - 10
		speedBtn.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		gradientLayer.frame = layer.bounds
		
		fullScreenBtn.isHidden = true
		speedBtn.isHidden = false
		
	}
}
