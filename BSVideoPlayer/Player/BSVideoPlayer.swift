//
//  BSPlayerLayerView.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/9/18.
//

import Foundation
import UIKit
import AVFoundation

public protocol BSVideoPlayerDelegate: AnyObject {
	func playerViewClickBack(playerView: BSVideoPlayer)
	func playerView(playerView: BSVideoPlayer, shouldRotateTo orientation: UIInterfaceOrientation)
	func playerView(playerView: BSVideoPlayer, didRotateTo orienttation: UIInterfaceOrientation)
	
	// state == 0 渐出
	// state == 1 渐入
	func playerView(playerView: BSVideoPlayer, controllViewWillFade state: Int)
	func playerView(playerView: BSVideoPlayer, controllViewDidFade state: Int)
}

public struct BSVideoPlayerConfig {
	
	public let url: String
	
	// 是否自动播放
	public let shouldAutoPlay: Bool
	
	//x系列手机(刘海屏)，在全屏状态下是否全填充屏幕
	public let isXSeriesAspectFill: Bool
	
	// 非刘海屏手机播放器的frame没有给statusBar预留间隙时，设置该值为true，可以使子view在竖屏时自动向下便宜
	public let isAvoidTheStatusBar: Bool
	
	public init(url: String, shouldAutoPlay: Bool = true, isXSeriesAspectFill: Bool = false, isAvoidTheStatusBar: Bool = true) {
		self.url = url
		self.shouldAutoPlay = shouldAutoPlay
		self.isXSeriesAspectFill = isXSeriesAspectFill
		if UIDevice.current.isXSeries() {
			self.isAvoidTheStatusBar = false
		}
		else {
			self.isAvoidTheStatusBar = isAvoidTheStatusBar
		}
	}
}

open class PlayerView: UIView {
	public override class var layerClass: AnyClass {
		return AVPlayerLayer.self
	}
	
	public var playerLayer: AVPlayerLayer {
		return layer as! AVPlayerLayer
	}

	public var vPlayer: AVPlayer? {
		get {
			return self.playerLayer.player
		}
		set {
			self.playerLayer.player = newValue
		}
	}
	
	public override var contentMode: UIView.ContentMode {
		didSet {
			switch contentMode {
			case .scaleToFill:
				self.playerLayer.videoGravity = AVLayerVideoGravity.resize
			case .scaleAspectFit:
				self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
			case .scaleAspectFill:
				self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
			default:
				self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
			}
		}
	}
	
	public var isReadyForDisplay: Bool {
		return self.playerLayer.isReadyForDisplay
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		contentMode = .scaleAspectFit
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		contentMode = .scaleAspectFit
	}
}

public class BSVideoPlayer: PlayerView, UIGestureRecognizerDelegate {
	
	public weak var delegate: BSVideoPlayerDelegate?
	
	public private(set) var isLockScreen = false
	
	public private(set) var isPortrait = true {
		didSet {
			lockBtn.isHidden = isPortrait
			backBtn.isHidden = !isPortrait
			controlBar.isPortrait = isPortrait
			topView.isPortrait = isPortrait
			topView.isHidden = isPortrait
			if isSubViewShouldHide {
				topView.alpha = 0
			}
		}
	}
	
	public private(set) var url: String
	
	public private(set) var controlBar: BSPlayerControlBar
	
	public private(set) var topView: BSPlayerTopView
	
	public private(set) var stepView: BSPlayerStepView
	
	public private(set) var player: BSPlayer!
	
	public private(set) var statusBar: BSPlayerStatusBar
	
	public private(set) var lockBtn: VExpandButton
	
	public private(set) var backBtn: VExpandButton
	
	public private(set) var speedView: BSPlayerSpeedView?
	
	private var portraitInfo: PortraitStateInfo?
	
	private var fullScreenContainerView: UIView {
		return UIApplication.shared.keyWindow!
	}
	
	private var tapGes: UITapGestureRecognizer!
	
	private var panGes: UIPanGestureRecognizer!
	
	private var doubleGes: UITapGestureRecognizer!
	
	private var isSubViewShouldHide = false
	
	private var panStartP = CGPoint.zero
	
	private(set) var config: BSVideoPlayerConfig
	
	private(set) var lastOrientation: UIInterfaceOrientation

	public init(url: String, frame: CGRect, config: BSVideoPlayerConfig) {
		self.url = url
		self.config = config
		controlBar = BSPlayerControlBar.init(frame: CGRect.init(x: 0, y: frame.height - 45, width: frame.width, height: 45))
		topView = BSPlayerTopView.init(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: 45))
		lockBtn = VExpandButton.init(type: .custom)
		stepView = BSPlayerStepView.init(frame: CGRect.init(x: frame.width/2 - 60, y: frame.height/2 - 25, width: 120, height: 50))
		statusBar = BSPlayerStatusBar.init(frame: CGRect.zero)
		backBtn = VExpandButton.init(type: .custom)
		lastOrientation = UIApplication.shared.statusBarOrientation
		super.init(frame: frame)
		
		contentMode = .scaleAspectFit

		backgroundColor = UIColor.black
		
		player = BSPlayer.init(url: url, delegate: self)
		vPlayer = player.player
		
		addSubview(controlBar)
		controlBar.sliderValueChangedBl = { [unowned self] (value) in
			self.player(player: self.player, currentTimeChanged: Int(value*Float(self.player.duration)))
		}
		controlBar.sliderTouchBeganBl = { [unowned self] (value) in
			self.player.pause()
		}
		controlBar.sliderTouchEndBl = { [unowned self] (value) in
			self.player.seekToProgress(progress: Double(value))
		}
		controlBar.playClick = { [unowned self] (isSelected) in
			if isSelected {
				self.player.pause()
			}
			else {
				self.player.play()
			}
		}
		controlBar.fullScreenClick = { [unowned self] (isSelected) in
			self.setFullScreen()
		}
		controlBar.speedClick = { [unowned self] in
			if self.speedView == nil {
				var w: CGFloat = 80
				if #available(iOS 11.0, *) {
					w = w + (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft ? UIApplication.shared.keyWindow!.safeAreaInsets.right : UIApplication.shared.keyWindow!.safeAreaInsets.left)
				}
				self.speedView = BSPlayerSpeedView.init(frame: CGRect.init(x: UIScreen.main.bounds.width, y: 0, width: w, height: UIScreen.main.bounds.height), datas: [
					SpeedViewModel.init(desc: "2.0x", speed: 2.0, isSelected: false),
					SpeedViewModel.init(desc: "1.5x", speed: 1.5, isSelected: false),
					SpeedViewModel.init(desc: "1.25x", speed: 1.25, isSelected: false),
					SpeedViewModel.init(desc: "1.0x", speed: 1.0, isSelected: false),
					SpeedViewModel.init(desc: "0.75x", speed: 0.75, isSelected: false),
					SpeedViewModel.init(desc: "0.5x", speed: 0.5, isSelected: false),
				])
			}
			self.speedView!.didSelectedSpeed = { (speed) in
				self.player?.rate = speed.speed
				var text = speed.desc
				if speed.speed == 1.0 {
					text = "倍速"
				}
				self.controlBar.speed = text
				self.speedView?.dismiss()
			}
			self.addSubview(self.speedView!)
			self.speedView!.show()
		}
		
		topView.isHidden = true
		topView.clickBackBlock = { [unowned self] in
			if self.isPortrait {
				self.delegate?.playerViewClickBack(playerView: self)
			}
			else {
				self.setPortrait()
			}
		}
		addSubview(topView)
		
		statusBar.isHidden = true
		statusBar.alpha = 0
		addSubview(statusBar)
		
		addSubview(lockBtn)
		lockBtn.setBackgroundImage(UIImage.init(named: "unlock"), for: .normal)
		lockBtn.setBackgroundImage(UIImage.init(named: "lock"), for: .selected)
		lockBtn.addTarget(self, action: #selector(clickLock), for: .touchUpInside)
		lockBtn.isHidden = true
		
		backBtn.setBackgroundImage(UIImage.init(named: "back"), for: .normal)
		backBtn.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
		backBtn.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
		addSubview(backBtn)
		
		addSubview(stepView)
		stepView.isHidden = true
		
		tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tap))
		tapGes.numberOfTapsRequired = 1
		tapGes.delegate = self
		addGestureRecognizer(tapGes)
		
		panGes = UIPanGestureRecognizer.init(target: self, action: #selector(pan))
		addGestureRecognizer(panGes)
		
		doubleGes = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap))
		doubleGes.numberOfTapsRequired = 2
		addGestureRecognizer(doubleGes)
		
		delayControllViewFadeOut()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		PlayerLoger.info(log: "BSVideoPlayer deinit")
		UIDevice.current.endGeneratingDeviceOrientationNotifications()
		NotificationCenter.default.removeObserver(self)
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		let w = max(width, height)
		let h = min(width, height)
		controlBar.frame = CGRect.init(x: 0, y: h - (isPortrait ? 45 : 90), width: w, height: isPortrait ? 45 : 90)
		topView.frame = CGRect.init(x: 0, y: 0, width: w, height: 45)
		lockBtn.frame = CGRect.init(x: 20, y: h/2 - 15, width: 30, height: 30)
		stepView.frame = CGRect.init(x: w/2 - 60, y: h/2 - 30, width: 110, height: 60)
		statusBar.frame = CGRect.init(x: 0, y: 0, width: w, height: 20)
		backBtn.frame = CGRect.init(x: 10, y: config.isAvoidTheStatusBar ? landscapeStatusBarHeigth + 5 : 10, width: 25, height: 25);
		backBtn.layer.cornerRadius = 25.0/2
	}
	
	
	public func shutdown() {
		player.shutdown()
	}
	
	//MARK: - Ation
//	@objc private func tap() {
//		if isLockScreen {
//			self.lockBtn.alpha = 1
//			return
//		}
//		if speedView != nil && !speedView!.isHidden {
//			speedView?.dismiss()
//			return
//		}
//		if isSubViewShouldHide {
//			controllViewAutoFadeIn()
//			delayControllViewFadeOut()
//		}
//		else {
//			controllViewAutoFadeOut()
//		}
//	}
//
//	@objc private func pan() {
//		if isLockScreen {
//			self.lockBtn.alpha = 1
//			return
//		}
//		if player.state != .playing && player.state != .paused {
//			return
//		}
//		//默认从最左变滑到最右边为三分钟
//		if panGes.state == .began {
//			panStartP = panGes.location(in: self)
//			stepView.isHidden = false
//			player.pause()
//		}
//		else if panGes.state == .changed {
//			let currentP = panGes.location(in: self)
//			let x = currentP.x - panStartP.x
//			let panTime = Int((x/width)*3*60)
//			var seekTime = player.currentTime + panTime < 0 ? 0 : player.currentTime + panTime
//			seekTime = seekTime > player.duration ? player.duration : seekTime
//			stepView.currentTime = seekTime
//			stepView.value = Float(seekTime)/Float(player.duration)
//		}
//		else if panGes.state == .ended {
//			stepView.isHidden = true
//			let currentP = panGes.location(in: self)
//			let x = currentP.x - panStartP.x
//			let panTime = Int((x/width)*3*60)
//			var seekTime = player.currentTime + panTime < 0 ? 0 : player.currentTime + panTime
//			seekTime = seekTime > player.duration ? player.duration : seekTime
//			player.seekToTime(seekTime: seekTime)
//		}
//		else if panGes.state == .cancelled {
//			stepView.isHidden = true
//		}
//	}
//
//	@objc private func doubleTap() {
//		if isLockScreen {
//			self.lockBtn.alpha = 1
//			return
//		}
//		if player.isPlaying {
//			player.pause()
//		}
//		else {
//			player.play()
//		}
//	}
//
//	@objc private func clickLock() {
//		if lockBtn.isSelected {
//			// 解锁
//			isLockScreen = false
//			controllViewAutoFadeIn()
//		}
//		else {
//			// 锁
//			isLockScreen = true
//			controllViewAutoFadeOut()
//		}
//		lockBtn.isSelected = !lockBtn.isSelected
//	}
//
//	@objc private func clickBack() {
//		delegate?.playerViewClickBack(playerView: self)
//	}
//
//	//MARK: - UIGestureRecognizerDelegate
//	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//		if speedView != nil && !speedView!.isHidden {
//			let p = gestureRecognizer.location(in: gestureRecognizer.view)
//			let flag = speedView!.frame.contains(p)
//			return !flag
//		}
//		return true
//	}
//
////	//MARK: - VideoPlayeDelegate
////	func player(player: BSPlayer, currentTimeChanged time: Int) {
////		controlBar.curremTime = time
////		controlBar.playProgress = Float(time)/Float(player.duration)
////	}
////
////	func player(player: BSPlayer, stateChanged state: BSPlayer.State) {
////		PlayerLoger.info(log: "state changed = \(state)")
////		switch state {
////		case .unknow:
////			break
////		case .prepareToPlay:
////			break
////		case .buffing:
////			break
////		case .readyToPlay:
////			break
////		case .paused:
////			controlBar.isPlaying = false
////			break
////		case .playing:
////			controlBar.isPlaying = true
////			break
////		case .seeking:
////			break
////		case .stoped:
////			break
////		case .playToEnd:
////			controlBar.isPlaying = false
////			break
////		case .failed:
////			break
////		}
////	}
////
////	func player(player: BSPlayer, durationChanged duration: Int) {
////		controlBar.duration = duration
////		stepView.duration = duration
////	}
////
////	func player(player: BSPlayer, bufferTimeChanged buffringTime: Int) {
////		let progress = Float(buffringTime)/Float(player.duration)
////		controlBar.bufferProgress = progress
////	}
////
////	func player(player: BSPlayer, unexceptedErrorOccur error: Error) {
////		PlayerLoger.error(log: error.localizedDescription)
////	}
//
//
//	//MARK: - Private
//
//	//隐藏控制view
//	private func delayControllViewFadeOut() {
//		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(controllViewAutoFadeOut), object: nil)
//		perform(#selector(controllViewAutoFadeOut), with: nil, afterDelay: 5)
//	}
//
//	//显示控制view
//	private func delayControllViewFadeIn() {
//		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(controllViewAutoFadeIn), object: nil)
//		perform(#selector(controllViewAutoFadeIn), with: nil, afterDelay: 5)
//	}
//
//	@objc private func controllViewAutoFadeOut() {
//		isSubViewShouldHide = true
//		delegate?.playerView(playerView: self, controllViewWillFade: 0)
//		UIView.animate(withDuration: 0.25) {
//			self.controlBar.alpha = 0
//			self.lockBtn.alpha = 0
//			if !self.isPortrait {
//				self.topView.alpha = 0
//				self.statusBar.alpha = 0
//				self.statusBar.stopMonitor()
//			}
//		} completion: { (flag) in
//			self.delegate?.playerView(playerView: self, controllViewDidFade: 0)
//		}
//	}
//
//	@objc private func controllViewAutoFadeIn() {
//		isSubViewShouldHide = false
//		delegate?.playerView(playerView: self, controllViewWillFade: 1)
//		UIView.animate(withDuration: 0.25) {
//			self.controlBar.alpha = 1.0
//			self.lockBtn.alpha = 1.0
//			if !self.isPortrait {
//				self.topView.alpha = 1.0
//				self.statusBar.alpha = 1.0
//				self.statusBar.startMonitor()
//			}
//		} completion: { (flag) in
//			self.delegate?.playerView(playerView: self, controllViewDidFade: 0)
//		}
//	}
	
//	private func getStatusBarAppearanceState() -> Bool {
//		let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
//		let dic = NSDictionary.init(contentsOf: URL.init(fileURLWithPath: path))
//		let flag = dic!["UIViewControllerBasedStatusBarAppearance"]
//		return flag! as! Bool
//	}
}

// 手势交互
extension BSVideoPlayer {
	@objc private func tap() {
		if isLockScreen {
			self.lockBtn.alpha = 1
			return
		}
		if speedView != nil && !speedView!.isHidden {
			speedView?.dismiss()
			return
		}
		if isSubViewShouldHide {
			controllViewAutoFadeIn()
			delayControllViewFadeOut()
		}
		else {
			controllViewAutoFadeOut()
		}
	}
	
	@objc private func pan() {
		if isLockScreen {
			self.lockBtn.alpha = 1
			return
		}
		if player.state != .playing && player.state != .paused {
			return
		}
		//默认从最左变滑到最右边为三分钟
		if panGes.state == .began {
			panStartP = panGes.location(in: self)
			stepView.isHidden = false
			player.pause()
		}
		else if panGes.state == .changed {
			let currentP = panGes.location(in: self)
			let x = currentP.x - panStartP.x
			let panTime = Int((x/width)*3*60)
			var seekTime = player.currentTime + panTime < 0 ? 0 : player.currentTime + panTime
			seekTime = seekTime > player.duration ? player.duration : seekTime
			stepView.currentTime = seekTime
			stepView.value = Float(seekTime)/Float(player.duration)
		}
		else if panGes.state == .ended {
			stepView.isHidden = true
			let currentP = panGes.location(in: self)
			let x = currentP.x - panStartP.x
			let panTime = Int((x/width)*3*60)
			var seekTime = player.currentTime + panTime < 0 ? 0 : player.currentTime + panTime
			seekTime = seekTime > player.duration ? player.duration : seekTime
			player.seekToTime(seekTime: seekTime)
		}
		else if panGes.state == .cancelled {
			stepView.isHidden = true
		}
	}
	
	@objc private func doubleTap() {
		if isLockScreen {
			self.lockBtn.alpha = 1
			return
		}
		if player.isPlaying {
			player.pause()
		}
		else {
			player.play()
		}
	}
	
	@objc private func clickLock() {
		if lockBtn.isSelected {
			// 解锁
			isLockScreen = false
			controllViewAutoFadeIn()
		}
		else {
			// 锁
			isLockScreen = true
			controllViewAutoFadeOut()
		}
		lockBtn.isSelected = !lockBtn.isSelected
	}
	
	@objc private func clickBack() {
		delegate?.playerViewClickBack(playerView: self)
	}
	
	//MARK: - UIGestureRecognizerDelegate
	public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if speedView != nil && !speedView!.isHidden {
			let p = gestureRecognizer.location(in: gestureRecognizer.view)
			let flag = speedView!.frame.contains(p)
			return !flag
		}
		return true
	}
	
//	//MARK: - VideoPlayeDelegate
//	func player(player: BSPlayer, currentTimeChanged time: Int) {
//		controlBar.curremTime = time
//		controlBar.playProgress = Float(time)/Float(player.duration)
//	}
//
//	func player(player: BSPlayer, stateChanged state: BSPlayer.State) {
//		PlayerLoger.info(log: "state changed = \(state)")
//		switch state {
//		case .unknow:
//			break
//		case .prepareToPlay:
//			break
//		case .buffing:
//			break
//		case .readyToPlay:
//			break
//		case .paused:
//			controlBar.isPlaying = false
//			break
//		case .playing:
//			controlBar.isPlaying = true
//			break
//		case .seeking:
//			break
//		case .stoped:
//			break
//		case .playToEnd:
//			controlBar.isPlaying = false
//			break
//		case .failed:
//			break
//		}
//	}
//
//	func player(player: BSPlayer, durationChanged duration: Int) {
//		controlBar.duration = duration
//		stepView.duration = duration
//	}
//
//	func player(player: BSPlayer, bufferTimeChanged buffringTime: Int) {
//		let progress = Float(buffringTime)/Float(player.duration)
//		controlBar.bufferProgress = progress
//	}
//
//	func player(player: BSPlayer, unexceptedErrorOccur error: Error) {
//		PlayerLoger.error(log: error.localizedDescription)
//	}

	
	//MARK: - Private
	
	//隐藏控制view
	private func delayControllViewFadeOut() {
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(controllViewAutoFadeOut), object: nil)
		perform(#selector(controllViewAutoFadeOut), with: nil, afterDelay: 5)
	}
	
	//显示控制view
	private func delayControllViewFadeIn() {
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(controllViewAutoFadeIn), object: nil)
		perform(#selector(controllViewAutoFadeIn), with: nil, afterDelay: 5)
	}
	
	@objc private func controllViewAutoFadeOut() {
		isSubViewShouldHide = true
		delegate?.playerView(playerView: self, controllViewWillFade: 0)
		UIView.animate(withDuration: 0.25) {
			self.controlBar.alpha = 0
			self.lockBtn.alpha = 0
			if !self.isPortrait {
				self.topView.alpha = 0
				self.statusBar.alpha = 0
				self.statusBar.stopMonitor()
			}
		} completion: { (flag) in
			self.delegate?.playerView(playerView: self, controllViewDidFade: 0)
		}
	}
	
	@objc private func controllViewAutoFadeIn() {
		isSubViewShouldHide = false
		delegate?.playerView(playerView: self, controllViewWillFade: 1)
		UIView.animate(withDuration: 0.25) {
			self.controlBar.alpha = 1.0
			self.lockBtn.alpha = 1.0
			if !self.isPortrait {
				self.topView.alpha = 1.0
				self.statusBar.alpha = 1.0
				self.statusBar.startMonitor()
			}
		} completion: { (flag) in
			self.delegate?.playerView(playerView: self, controllViewDidFade: 0)
		}
	}
}

//MARK:-BSPlayerDelegate
extension BSVideoPlayer: BSPlayerDelegate {
	public func player(player: BSPlayer, currentTimeChanged time: Int) {
		controlBar.curremTime = time
		controlBar.playProgress = Float(time)/Float(player.duration)
	}
	
	public func player(player: BSPlayer, stateChanged state: BSPlayer.State) {
		PlayerLoger.info(log: "state changed = \(state)")
		switch state {
		case .unknow:
			break
		case .prepareToPlay:
			break
		case .buffing:
			break
		case .readyToPlay:
			break
		case .paused:
			controlBar.isPlaying = false
			break
		case .playing:
			controlBar.isPlaying = true
			break
		case .seeking:
			break
		case .stoped:
			break
		case .playToEnd:
			controlBar.isPlaying = false
			break
		case .failed:
			break
		}
	}
	
	public func player(player: BSPlayer, durationChanged duration: Int) {
		controlBar.duration = duration
		stepView.duration = duration
	}
	
	public func player(player: BSPlayer, bufferTimeChanged buffringTime: Int) {
		let progress = Float(buffringTime)/Float(player.duration)
		controlBar.bufferProgress = progress
	}
	
	public func player(player: BSPlayer, unexceptedErrorOccur error: Error) {
		PlayerLoger.error(log: error.localizedDescription)
	}
}

// Rotate
extension BSVideoPlayer {
	// 旋转至竖屏
	private func setPortrait() {
		guard self.portraitInfo != nil else {
			return
		}
		rotateToOrientation(orientation: UIInterfaceOrientation.portrait)
	}
	
	// 旋转至全屏
	// 默认的旋转反向是听筒在左侧
	private func setFullScreen(ori: UIInterfaceOrientation = UIInterfaceOrientation.landscapeRight) {
		rotateToOrientation(orientation: UIInterfaceOrientation.landscapeRight)
	}
	
	public var shouldAutorotate: Bool {
		return !isLockScreen
	}
	
	public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		let interfaceOrientation = UIDevice.current.toInterfaceOrientation()
		if lastOrientation == interfaceOrientation {
			return
		}
		isPortrait = interfaceOrientation == UIInterfaceOrientation.portrait
		
		// 设置自定义的状态栏
		if interfaceOrientation == UIInterfaceOrientation.portrait {
			// 竖屏状态下停止监控 关闭timer
			statusBar.isHidden = true
			statusBar.stopMonitor()
		}
		else {
			statusBar.isHidden = false
			if !isSubViewShouldHide {
				statusBar.alpha = 1
			}
			statusBar.startMonitor()
		}
		
		var rect = CGRect.zero
		if interfaceOrientation == UIInterfaceOrientation.landscapeLeft || interfaceOrientation == UIInterfaceOrientation.landscapeRight {
			savePortraitInfo()
			var x: CGFloat = 0
			var w: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
			let h: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
			if #available(iOS 11.0, *), UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0.0 {
				if lastOrientation == UIInterfaceOrientation.landscapeLeft {
					x = UIApplication.shared.keyWindow!.safeAreaInsets.right
					w = w - UIApplication.shared.keyWindow!.safeAreaInsets.right - UIApplication.shared.keyWindow!.safeAreaInsets.left
				}
				else if lastOrientation == UIInterfaceOrientation.landscapeRight {
					x = UIApplication.shared.keyWindow!.safeAreaInsets.left
					w = w - UIApplication.shared.keyWindow!.safeAreaInsets.right - UIApplication.shared.keyWindow!.safeAreaInsets.left
				}
				else if lastOrientation == UIInterfaceOrientation.portrait {
					x = interfaceOrientation == UIInterfaceOrientation.landscapeLeft ? UIApplication.shared.keyWindow!.safeAreaInsets.top : UIApplication.shared.keyWindow!.safeAreaInsets.bottom
					w = w - UIApplication.shared.keyWindow!.safeAreaInsets.top - UIApplication.shared.keyWindow!.safeAreaInsets.bottom
				}
			}
			rect = CGRect.init(x: x, y: 0, width: w, height: h)
		}
		else {
			guard let portraitInfo = self.portraitInfo else {
				return
			}
			rect = portraitInfo.rect
		}
		
		delegate?.playerView(playerView: self, shouldRotateTo: interfaceOrientation)
		UIView.animate(withDuration: coordinator.transitionDuration, delay: 0, options: UIView.AnimationOptions.curveEaseIn) {
			self.frame = rect
		} completion: { (finished) in
			if interfaceOrientation == UIInterfaceOrientation.portrait {
				self.portraitInfo!.sView.insertSubview(self, at: self.portraitInfo!.level)
			}
			self.delegate?.playerView(playerView: self, didRotateTo: interfaceOrientation)
			self.lastOrientation = interfaceOrientation
		}
	}
	
	// 存储属性状态的信息以及一些旋转的前的准备工作
	private func savePortraitInfo() {
		self.portraitInfo = PortraitStateInfo.init(level: getOrderInSuperView(), rect: frame,sView: self.superview!)
		let rect = self.convert(self.frame, to: fullScreenContainerView)
		removeFromSuperview()
		fullScreenContainerView.addSubview(self)
		self.frame = rect
	}
	
	// 强制旋转
	func rotateToOrientation(orientation: UIInterfaceOrientation) {
		UIDevice.current.setValue(NSNumber.init(value: orientation.rawValue), forKey: "orientation")
		UIViewController.attemptRotationToDeviceOrientation()
	}
}

struct PortraitStateInfo {
	var level: Int
	var rect: CGRect
	var sView: UIView
}
