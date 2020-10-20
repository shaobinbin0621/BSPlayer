//
//  BSPlayerSubClass.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/9/30.
//

import Foundation
import UIKit

let landscapeStatusBarHeigth: CGFloat = 20.0

@available(iOS 11.0, *)
var xSeriesEdgeMaxValue: CGFloat {
	if UIApplication.shared.keyWindow == nil {
		return 0
	}
	return max(UIApplication.shared.keyWindow!.safeAreaInsets.bottom, UIApplication.shared.keyWindow!.safeAreaInsets.top)
}

public class VExpandButton: UIButton {
	public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let space: CGFloat = 10.0
		let rect = CGRect.init(x: -space, y: -space, width: width+space*2, height: height+space*2)
		return rect.contains(point)
	}
}

public class VSlider: UISlider {
	public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let space: CGFloat = 10.0
		let rect = CGRect.init(x: -space, y: -space, width: width+space*2, height: height+space*2)
		return rect.contains(point)
	}
}

extension Int {
	//转换数字为00:00:00样式字符串
	func transToHMS() -> String {
		let allTime: Int = Int(self)
		var hours = 0
		var minutes = 0
		var seconds = 0
		var hoursText = ""
		var minutesText = ""
		var secondsText = ""
		
		hours = allTime / 3600
		hoursText = hours > 9 ? "\(hours)" : "0\(hours)"
		
		minutes = allTime % 3600 / 60
		minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
		
		seconds = allTime % 3600 % 60
		secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
		
		return hoursText == "00" ? "\(minutesText):\(secondsText)" : "\(hoursText):\(minutesText):\(secondsText)"
	}
}

class PlayerLoger {
	
	static var level: LogLevel = .info
	
	enum LogLevel: Int {
		case info = 0
		case warning = 1
		case error = 2
	}
	
	
	
	static func info(log: String) {
		#if !DEBUG
			return
		#endif
		if level.rawValue > 0 {
			return
		}
		print("[\(Date.millesString())] : Info: \(log)")
	}
	static func warning(log: String) {
		#if !DEBUG
			return
		#endif
		if level.rawValue > 1 {
			return
		}
		print("[\(Date.millesString())] : Warning: \(log)")
	}
	static func error(log: String) {
		#if !DEBUG
			return
		#endif
		if level.rawValue > 2 {
			return
		}
		print("[\(Date.millesString())] : Error: \(log)")
	}
}

extension Timer {
	class func v_sheduledTimer(interval: TimeInterval, isRepeat: Bool, block: @escaping () -> Void) -> Timer {
		return Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(v_blockInvoke(timer:)), userInfo: block, repeats: isRepeat)
	}
	
	@objc class func v_blockInvoke(timer: Timer) {
		let block: (() -> Void)? = timer.userInfo as? () -> Void
		block?()
	}
}

