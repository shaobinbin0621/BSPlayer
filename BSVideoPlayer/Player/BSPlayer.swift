//
//  BSPlayer.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/9/18.
//

import Foundation
import AVFoundation
import UIKit

public protocol BSPlayerDelegate: AnyObject {
	func player(player: BSPlayer, currentTimeChanged time: Int)
	func player(player: BSPlayer, stateChanged state: BSPlayer.State)
	func	player(player: BSPlayer, durationChanged duration: Int)
	func player(player: BSPlayer, bufferTimeChanged buffringTime: Int)
	func player(player: BSPlayer, unexceptedErrorOccur error: Error)
}

public class BSPlayer: NSObject {
	
	public private(set) var urlAsset: AVURLAsset?
	public private(set) var player: AVPlayer?
	public private(set) var playerItem: AVPlayerItem?
	
	public var isPlaying: Bool {
		get {
			return state == .playing
		}
	}
	
	public var duration: Int {
		get {
			if playerItem == nil {
				return 0
			}
			return CMTimeGetSeconds(playerItem!.duration).safeToInt()
		}
	}
	
	public var currentTime: Int {
		get {
			if player == nil {
				return 0
			}
			return CMTimeGetSeconds(player!.currentTime()).safeToInt()
		}
	}
	
	public var mute: Bool {
		get {
			if player == nil {
				return false
			}
			return player!.isMuted
		}
		set {
			if player != nil {
				player!.isMuted = newValue
			}
		}
	}
	
	public var isLocal: Bool {
		get {
			return url.hasPrefix("file://")
		}
	}
	
	private var playUrl: URL? {
		get {
			if isLocal {
				return URL.init(fileURLWithPath: url)
			}
			else {
				return URL.init(string: url)
			}
		}
	}
	
	// 设置播放速度
	public var rate: Float {
		get {
			if player == nil {
				return 0
			}
			return player!.rate
		}
		set {
			player?.rate = newValue
		}
	}
	
	public private(set) var shouldAutoPlay: Bool
	
	// 播放初始的播放时间
	public private(set) var playbackStartTime = 0
	
	public private(set) var url: String!
	
	weak public private(set) var delegate: BSPlayerDelegate?
	
	public enum State: Int {
		case unknow
		case prepareToPlay
		case buffing
		case readyToPlay
		case paused
		case playing
		case seeking
		case stoped
		case playToEnd
		case failed
	}
	
	public private(set) var state: State = .unknow {
		didSet {
			delegate?.player(player: self, stateChanged: state)
		}
	}

	private var playerTimeObserver: Any?
	
	private var playerItemReady: Bool {
		return playerItem?.status == AVPlayerItem.Status.readyToPlay
	}
	
	private var canPlay: Bool {
		if playerItem == nil {
			return false
		}
		return playerItem!.isPlaybackLikelyToKeepUp
	}
	
	public init(url: String, delegate: BSPlayerDelegate?, shouldAutoPlay: Bool = true, playbackStartTime: Int = 0) {
		self.delegate = delegate
		self.url = url
		self.shouldAutoPlay = shouldAutoPlay
		self.playbackStartTime = playbackStartTime
		super.init()
		prepareToPlay()
	}
	
	//MARK:-Public
	public func play() {
		guard player != nil && playerItem != nil else {
			return
		}
		if playerItem!.status != .readyToPlay || !playerItem!.isPlaybackLikelyToKeepUp {
			return ;
		}
		if state == .playToEnd {
			player?.seek(to: CMTime.zero, completionHandler: { (finished) in
				if !finished {
					return
				}
				self.player?.play()
				self.state = .playing
			})
			return
		}
		player!.play()
		state = .playing
	}
	
	public func pause() {
		guard player != nil else {
			return
		}
		player!.pause()
		state = .paused
	}
	
	public func stop() {
		player?.pause()
		state = .stoped
		player?.seek(to: CMTime.zero)
	}
	
	public func shutdown() {
		stop()
		removePlayItemObserver()
		removePlayerTimeObserver()
		player = nil
		playerItem = nil
		urlAsset = nil
	}
	
	public func seekToTime(seekTime: Int) {
		if player == nil || state == .seeking || playerItem?.status != AVPlayerItem.Status.readyToPlay {
			return
		}
		let cms = CMTimeMakeWithSeconds(Float64(seekTime), preferredTimescale: Int32(NSEC_PER_SEC))
		player?.pause()
		state = .seeking
		player?.seek(to: cms, completionHandler: { (finished) in
			// finished为true时，代表这次的seek完成；finished为false时，代表此次seek被另一个seek打断了，或者暂停等其他操作，
			// 当被打断之后，这个block立即执行，并返回false
			if !finished {
				return
			}
			self.play()
		})
	}
	
	public func seekToProgress(progress: Double) {
		guard playerItem != nil else {
			return
		}
		let time = CMTimeGetSeconds(playerItem!.duration) * progress
		seekToTime(seekTime: time.safeToInt())
	}
	
	public func replacePlay(url: String) {
		self.url = url
		prepareToPlay()
	}
	
	public func reset() {
		stop()
	}
	
	//MARK: - Private
	private func prepareToPlay(){
		if playUrl == nil {
			assert(false, "Error: 输入了不合法的url \(String(describing: url))")
			PlayerLoger.error(log: "Error: 输入了不合法的url \(String(describing: url))")
			return
		}
		state = .prepareToPlay
		urlAsset = AVURLAsset.init(url: playUrl!)
		playerItem = AVPlayerItem.init(asset: urlAsset!)
		addPlayItemObserver()
		if player != nil {
			player!.replaceCurrentItem(with: playerItem)
		}
		else {
			player = AVPlayer.init(playerItem: playerItem)
		}
		player?.actionAtItemEnd = .pause
		addPlayerTimeObserver()
	}
	
	private func addPlayerTimeObserver(){
		guard player != nil && playerItem != nil else {
			return
		}
		removePlayerTimeObserver()
		playerTimeObserver = player!.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: nil, using: { [weak self] (time) in
			if self?.playerItem!.duration.timescale == 0 {
				return
			}
			if (self?.playerItem!.seekableTimeRanges.count)! <= 0 {
				return
			}
			let currentTime = CMTimeGetSeconds((self?.playerItem!.currentTime())!)
			self?.delegate?.player(player: self!, currentTimeChanged: currentTime.safeToInt())
//			self?.delegate?.playerCurrentTimeChanged(player: self!, time: currentTime.safeToInt())
		})
	}
	
	private func removePlayerTimeObserver() {
		if let ob = playerTimeObserver {
			player?.removeTimeObserver(ob)
		}
	}
	
	private func addPlayItemObserver() {
		guard playerItem != nil else {
			return
		}
		removePlayItemObserver()
		playerItem!.safe_addObserver(self, forKeyPath: "status", options: .new, context: nil)
		playerItem!.safe_addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
		playerItem!.safe_addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
		playerItem!.safe_addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(playerItemPlayToEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
	}
	
	@objc private func playerItemPlayToEnd() {
		state = .playToEnd
		delegate?.player(player: self, currentTimeChanged: 0)
	}
	
	private func removePlayItemObserver() {
		guard playerItem != nil else {
			return
		}
		NotificationCenter.default.removeObserver(self)
		playerItem!.safe_removeObserver(self, forKeyPath: "status")
		playerItem!.safe_removeObserver(self, forKeyPath: "loadedTimeRanges")
		playerItem!.safe_removeObserver(self, forKeyPath: "playbackBufferEmpty")
		playerItem!.safe_removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
	}
	
	private func availableBufferDuration() -> TimeInterval? {
		guard player != nil else {
			return nil
		}
		let loaded = player!.currentItem?.loadedTimeRanges
		let timeRange = loaded?.first?.timeRangeValue
		if timeRange == nil {
			return nil
		}
		let start = CMTimeGetSeconds(timeRange!.start)
		let duration = CMTimeGetSeconds(timeRange!.duration)
		return start + duration
	}
	
	func uneceptedErrorOccur(error: Error) {
		PlayerLoger.error(log: "Error: \(error)")
		delegate?.player(player: self, unexceptedErrorOccur: error)
	}
	
	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "status" {
			let status = (change![NSKeyValueChangeKey.newKey] as! NSNumber).intValue
			if status == AVPlayerItem.Status.readyToPlay.rawValue {
				state = .readyToPlay
				delegate?.player(player: self, durationChanged: self.duration)
//				delegate?.playerDurationChanged(player: self, duration: self.duration)
//				loadAssetDidCompleted?(nil)
				//playerItem加载完成并不代表可以播放了，需要检查下面属性的值
				if !playerItem!.isPlaybackLikelyToKeepUp {
					return
				}
				if shouldAutoPlay {
					player?.play()
					state = .playing
				}
				if playbackStartTime != 0 {
					seekToTime(seekTime: playbackStartTime)
				}
			}
			else if status == AVPlayerItem.Status.failed.rawValue {
				state = .failed
				uneceptedErrorOccur(error: playerItem!.error!)
			}
			else if status == AVPlayerItem.Status.unknown.rawValue {
				state = .unknow
			}
		}
		else if keyPath == "loadedTimeRanges" {
			if playerItem!.status != AVPlayerItem.Status.readyToPlay {
				return
			}
			if let bufferDuration = availableBufferDuration() {
				delegate?.player(player: self, bufferTimeChanged: bufferDuration.safeToInt())
			}
		}
		else if keyPath == "playbackBufferEmpty" {
			PlayerLoger.info(log: "isPlaybackBufferEmpty = \(playerItem!.isPlaybackBufferEmpty)")
			if playerItem!.isPlaybackBufferEmpty {
				state = .buffing
			}
		}
		else if keyPath == "playbackLikelyToKeepUp" {
			if !playerItem!.isPlaybackLikelyToKeepUp {
				state = .buffing
			}
			if state == .readyToPlay && playerItem!.isPlaybackLikelyToKeepUp {
				PlayerLoger.info(log: "isPlaybackLikelyToKeepUp = \(playerItem!.isPlaybackLikelyToKeepUp)")
				// playerItem加载完成之后，视频并不能立即播放(isPlaybackLikelyToKeepUp == false)
				// 只有当isPlaybackLikelyToKeepUp == true才可以播放
				if shouldAutoPlay {
					player?.play()
					state = .playing
				}
				if playbackStartTime != 0 {
					seekToTime(seekTime: playbackStartTime)
				}
			}
			// 播放出现卡顿之后，又可以继续播放了
			else if state == .buffing && playerItem!.isPlaybackLikelyToKeepUp {
				play()
			}
		}
	}
	
	deinit {
		PlayerLoger.info(log: "BSPlayer deinit")
		self.removePlayItemObserver()
		self.removePlayerTimeObserver()
	}
	
}

fileprivate var observerPropertyNameKey = "observerPropertyNameKey"
fileprivate extension NSObject {
	
	var observedProperties: [String:Any]? {
		set {
			objc_setAssociatedObject(self, &observerPropertyNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
		get {
			return objc_getAssociatedObject(self, &observerPropertyNameKey) as? [String:Any]
		}
	}
	
	/**
	* 线程不安全
	*/
	func safe_addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?) {
		assert(keyPath.count != 0, "keyPath.count == 0")
		if observedProperties != nil && observedProperties![keyPath] != nil {
//			PlayerLoger.info(log: "Warning: 已经添加过观察者了")
			return
		}
		if observedProperties == nil {
			observedProperties = [String:Bool]()
		}
		observedProperties![keyPath] = true
		addObserver(observer, forKeyPath: keyPath, options: options, context: context)
	}
	
	func safe_removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
		if observedProperties == nil || observedProperties![keyPath] == nil {
//			PlayerLoger.info(log: "Warning: 观察者已经被移除或者并未给该属性添加观察者, observer = \(observer), keyPath = \(keyPath) ")
			return
		}
		observedProperties!.removeValue(forKey: keyPath)
		if observedProperties!.count == 0 {
			observedProperties = nil
		}
		removeObserver(observer, forKeyPath: keyPath)
	}
}
