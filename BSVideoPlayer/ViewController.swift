//
//  ViewController.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/9/18.
//

import UIKit
import AVFoundation

class NC: UINavigationController {
	override var shouldAutorotate: Bool {
		return topViewController!.shouldAutorotate
	}
	
	override var childForStatusBarHidden: UIViewController? {
		return topViewController
	}
}

class ViewController: UIViewController, BSVideoPlayerDelegate {
	func playerViewClickBack(playerView: BSVideoPlayer) {
		
	}
	
	func playerView(playerView: BSVideoPlayer, shouldRotateTo orientation: UIInterfaceOrientation) {
		
	}
	
	func playerView(playerView: BSVideoPlayer, didRotateTo orienttation: UIInterfaceOrientation) {
		
	}
	
	func playerView(playerView: BSVideoPlayer, controllViewWillFade state: Int) {
		
	}
	
	func playerView(playerView: BSVideoPlayer, controllViewDidFade state: Int) {
		
	}
	
	
	var vPlayer: BSVideoPlayer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
//		loadInfoPlist()
		// 14:15
//		let url = "http://vt.hetaolive.com/d34ea1912b3e9a377cd31209823ea14d/5F88063C/mp4-hd/ad003a6ac2b24ae19bb5dc512d2c675e/hd1280/a2137a2ae8e39b5002a3f8909ecb88fe_0defd4a40ab1e458fb252af73f3644385.mp4"
		// 44:22
//		let url = "http://vt.hetaolive.com/4c22ee94c6d16d10088feac7eac0f313/6168F444/mp4-hd/39197b1e597646608c508fdaac5ecd67/hd1280/88a199611ac2b85bd3f76e8ee7e55650_0ec6b49f36fb14d46ae4d7450983c4780.mp4"
		let url = "https://vd4.bdstatic.com/mda-jg3pp0t2atgbjh5d/sc/mda-jg3pp0t2atgbjh5d.mp4?auth_key=1601173151-0-0-260509c2cb8752744f1c2b5652747ad1&bcevod_channel=searchbox_feed&pd=1&pt=3"
		var y: CGFloat = 64
		if #available(iOS 11.0, *) {
			y += view.safeAreaInsets.top
		}
		navigationController?.setNavigationBarHidden(true, animated: false)
		y = navigationController!.navigationBar.height + UIApplication.shared.statusBarFrame.height
		
		vPlayer = BSVideoPlayer.init(url: url, frame: CGRect.init(x: 0, y: y, width: view.frame.width, height: (9.0/16.0)*view.frame.width), config: BSVideoPlayerConfig.init(url: url))
		view.addSubview(vPlayer)
	}
	
	@objc func orient() {
		print("\(Date.millesString()) orient")
	}

	override var prefersStatusBarHidden: Bool {
		if vPlayer == nil {
			return false
		}
		if !vPlayer.isPortrait {
			return true
		}
		return true
	}
	
	override var shouldAutorotate: Bool {
		if vPlayer == nil {
			return true
		}
		return vPlayer.shouldAutorotate
	}
	
	var flag = true
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		vPlayer.viewWillTransition(to: size, with: coordinator)
	}
	
	private func loadInfoPlist() {
		let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
		let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path))
		let dic = NSDictionary.init(contentsOf: URL.init(fileURLWithPath: path))
		let flag = dic?["UIViewControllerBasedStatusBarAppearance"]
	}
	

	
	


}

class V: UIViewController {
	var vPlayer: BSVideoPlayer!
	override func viewDidLoad() {
		super.viewDidLoad()
		let url = "https://vd4.bdstatic.com/mda-jg3pp0t2atgbjh5d/sc/mda-jg3pp0t2atgbjh5d.mp4?auth_key=1601173151-0-0-260509c2cb8752744f1c2b5652747ad1&bcevod_channel=searchbox_feed&pd=1&pt=3"
		var y: CGFloat = 0
		if #available(iOS 11.0, *) {
			y = view.safeAreaInsets.top
		}
		vPlayer = BSVideoPlayer.init(url: url, frame: CGRect.init(x: 0, y: y, width: view.frame.width, height: (9.0/16.0)*view.frame.width), config: BSVideoPlayerConfig.init(url: url))
		view.addSubview(vPlayer)
		
		var p = BSPlayer.init(url: "", delegate: nil)
//		let a = p.urlAsset
//		p.urlAsset = nil
	}
	
	deinit {
		vPlayer.shutdown()
	}
	
	override var shouldAutorotate: Bool {
		return false
	}
	
}

