//
//  UIViewExtension.swift
//  photoalbum
//
//  Created by 未可知 on 2019/5/16.
//  Copyright © 2019 com.shao. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	
	var height: CGFloat {
		get {
			return self.frame.size.height
		}
		set {
			var rect = self.frame
			rect.size.height = newValue
			self.frame = rect
		}
	}
	
	var width: CGFloat {
		get {
			return self.frame.size.width
		}
		set {
			var rect = self.frame
			rect.size.width = newValue
			self.frame = rect
		}
	}
	
	var left: CGFloat {
		get {
			return self.frame.origin.x
		}
		set {
			var rect = self.frame
			rect.origin.x = newValue
			self.frame = rect
		}
	}
	
	var right: CGFloat {
		get {
			return self.frame.size.width + self.frame.origin.x
		}
		set {
			var rect = self.frame
			rect.origin.x = newValue - frame.size.width
			self.frame = rect
		}
	}
	
	var top: CGFloat {
		get {
			return self.frame.origin.y
		}
		set {
			var rect = self.frame
			rect.origin.y = newValue
			self.frame = rect
		}
	}
	
	var bottom: CGFloat {
		get {
			return self.frame.origin.y + frame.size.height
		}
		set {
			var rect = self.frame
			rect.origin.y = newValue - frame.size.height
			self.frame = rect
		}
	}
	
	var centerX: CGFloat {
		get {
			return frame.origin.x + frame.width/2
		}
		set {
			var rect = frame
			rect.origin.x = newValue - frame.width/2
			frame = rect
		}
	}
	
	var centerY: CGFloat {
		get {
			return frame.origin.y + frame.height/2
		}
		set {
			var rect = frame
			rect.origin.y = newValue - frame.height/2
			frame = rect
		}
	}
	
	func getOrderInSuperView() -> Int {
	   var level = 0
	   for v in superview!.subviews {
		   if v == self {
			   break
		   }
		   level+=1
	   }
	   return level
   }
	
}

extension UIView {
	var viewController: UIViewController? {
		get {
			var nexRes = self.next
			while nexRes != nil && !nexRes!.isKind(of: UIViewController.classForCoder()) {
				nexRes = nexRes?.next
			}
			return nexRes as? UIViewController
		}
	}
}

extension String {
	func getTextWidth(fontSize: CGFloat, h: CGFloat) -> CGFloat {
		return (self as NSString).boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: h), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize)], context: nil).size.width
	}
	
	func getTextWidth(font: UIFont, h: CGFloat) -> CGFloat {
		return (self as NSString).boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: h), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size.width
	}
	
	func getTextHeight(fontSize: CGFloat, w: CGFloat) -> CGFloat {
		return (self as NSString).boundingRect(with: CGSize.init(width: w, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize)], context: nil).size.height
	}
}

extension UIImage {
	func scalingToSize(size: CGSize) -> UIImage {
		let simage = self
		var newImage: UIImage?
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		var rect = CGRect.zero
		rect.origin = CGPoint.zero
		rect.size.width = size.width
		rect.size.height = size.height
		simage.draw(in: rect)
		newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage!
	}
}

extension UIDevice {
	func isXSeries() -> Bool {
		if UIApplication.shared.keyWindow == nil {
			PlayerLoger.info(log: "UIApplication.shared.keyWindow == nil")
			return false
		}
		if #available(iOS 11.0, *), UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0.0 {
			return true
		}
		return false
	}
	func toInterfaceOrientation() -> UIInterfaceOrientation {
		switch orientation {
		case .portrait:
			return UIInterfaceOrientation.portrait
		case .landscapeLeft:
			return UIInterfaceOrientation.landscapeLeft
		case .landscapeRight:
			return UIInterfaceOrientation.landscapeRight
		case .portraitUpsideDown:
			return UIInterfaceOrientation.portraitUpsideDown
		default:
			assert(false, "不合规的方向")
			return UIInterfaceOrientation.unknown
		}
	}
}

extension Date {
	static func dateStringHHmm() -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale.init(identifier: "zh_CN")
		formatter.dateFormat = "HH:mm"
		return formatter.string(from: Date())
	}
	static func millesString() -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale.init(identifier: "zh_CN")
		formatter.dateFormat = "HH:mm:ss.SSS"
		return formatter.string(from: Date())
	}
}

extension Double {
	func safeToInt() -> Int {
		if isNaN {
			return 0
		}
		if self > Double(Int.max) {
			return Int.max
		}
		return Int(self)
	}
}

