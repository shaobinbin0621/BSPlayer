//
//  BSPlayerStatusBar.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/10/12.
//

import Foundation
import UIKit

class BSPlayerBattery: UIView {
	
	var value: Float = 0 {
		didSet {
			let w: CGFloat = width - 3*2 - 1
			batteryValueView.frame = CGRect.init(origin: batteryValueView.frame.origin, size: CGSize.init(width: w*CGFloat(value), height: batteryValueView.width))
		}
	}
	
	private var batteryImg: UIImageView
	private var batteryValueView: UIView
	override init(frame: CGRect) {
		batteryImg = UIImageView.init()
		batteryValueView = UIView.init()
		super.init(frame: frame)
		
		batteryImg.image = UIImage.init(named: "battery")
		batteryImg.contentMode = .scaleToFill
		addSubview(batteryImg)
		
		// 45 202 70
		batteryValueView.backgroundColor = UIColor.init(red: 45.0/255.0, green: 202.0/255.0, blue: 70.0/255.0, alpha: 1.0)
		batteryValueView.layer.cornerRadius = 1
		addSubview(batteryValueView)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		var x: CGFloat = 0
		var y: CGFloat = 0
		var w: CGFloat = width
		var h: CGFloat = height
		batteryImg.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		x = 3
		y = 7
		w = width - x*2 - 1
		h = height - y*2
		batteryValueView.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
	}
	
}

class BSPlayerStatusBar: UIView {
	
	enum NetWorkType: String {
		case unknow = "无网络"
		case fourG = "4G"
		case fiveG = "5G"
		case wifi = "Wi-Fi"
	}
	
	private var timeLabel: UILabel
//	private var netDescLabel: UILabel
	private var rechargeImg: UIImageView
	private var batteryView: BSPlayerBattery
	
	private var timer: Timer?
	
//	var netType: NetWorkType? {
//		didSet {
//			switch netType {
//			case .fourG, .fiveG, .wifi:
//				netDescLabel.text = netType?.rawValue
//			default:
//				PlayerLoger.info(log: netType as Any)
//			}
//		}
//	}
	
	var isCharging: Bool {
		get {
			return UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
		}
		set {
			rechargeImg.isHidden = !newValue
			layoutIfNeeded()
		}
	}
	
	override init(frame: CGRect) {
		timeLabel = UILabel.init()
//		netDescLabel = UILabel.init()
		rechargeImg = UIImageView.init()
		batteryView = BSPlayerBattery.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: frame.height))
		super.init(frame: frame)
		
		timeLabel.textColor = UIColor.white
		timeLabel.font = UIFont.boldSystemFont(ofSize: 13)
		timeLabel.text = "00:00"
		timeLabel.textAlignment = .center
		addSubview(timeLabel)
		
//		netDescLabel.textColor = UIColor.white
//		netDescLabel.font = timeLabel.font
//		netDescLabel.isHidden = true
//		addSubview(netDescLabel)
		
		rechargeImg.image = UIImage.init(named: "recharge")
		rechargeImg.isHidden = true
		addSubview(rechargeImg)
		
		batteryView.value = 0
		addSubview(batteryView)
	
		UIDevice.current.isBatteryMonitoringEnabled = true
	}
	
	func startMonitor() {
		startTimer()
		addBatteryNotification()
	}
	
	func stopMonitor() {
		invalidateTimer()
		NotificationCenter.default.removeObserver(self)
	}
	
	deinit {
		stopMonitor()
		PlayerLoger.info(log: "BSPlayerStatusBar deinit")
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		var w: CGFloat = (timeLabel.text?.getTextWidth(font: timeLabel.font, h: 20))! + 5
		var x: CGFloat = width/2 - w/2
		var y: CGFloat = 0
		var h: CGFloat = height
		timeLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)

//		x = 5
//		w = 50
//		netDescLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		w = 11
		h = 11
		x = width - w - 3
		y = (height - h)/2
		rechargeImg.frame = CGRect.init(x: x, y: y, width: w, height: h)
		
		w = 25
		h = height
		y = 0
		if isCharging {
			x = width - rechargeImg.width - 1 - 3 - w
		}
		else {
			x = width - w - 3
		}
		batteryView.frame = CGRect.init(x: x, y: y, width: w, height: h)
	}
	
	private func startTimer() {
		invalidateTimer()
		timeLabel.text = Date.dateStringHHmm()
		timer = Timer.v_sheduledTimer(interval: 1, isRepeat: true) { [weak self] in
			self!.timeLabel.text = Date.dateStringHHmm()
		}
	}
	
	private func invalidateTimer() {
		timer?.invalidate()
		timer = nil
	}
	
	private func addBatteryNotification() {
		batterLevelChanged()
		batterStateChanged()
		NotificationCenter.default.addObserver(self, selector: #selector(batterLevelChanged), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(batterStateChanged), name: UIDevice.batteryStateDidChangeNotification, object: nil)
	}
	
	@objc private func batterLevelChanged() {
		batteryView.value = UIDevice.current.batteryLevel
	}
	
	@objc private func batterStateChanged() {
		isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
	}
}
