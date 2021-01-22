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
	var player: BSVideoPlayer!
	var urls = [
//	"http://vt.hetaolive.com/d34ea1912b3e9a377cd31209823ea14d/5F88063C/mp4-hd/ad003a6ac2b24ae19bb5dc512d2c675e/hd1280/a2137a2ae8e39b5002a3f8909ecb88fe_0defd4a40ab1e458fb252af73f3644385.mp4",
//	"http://vt.hetaolive.com/4c22ee94c6d16d10088feac7eac0f313/6168F444/mp4-hd/39197b1e597646608c508fdaac5ecd67/hd1280/88a199611ac2b85bd3f76e8ee7e55650_0ec6b49f36fb14d46ae4d7450983c4780.mp4",
	 "https://vd4.bdstatic.com/mda-jg3pp0t2atgbjh5d/sc/mda-jg3pp0t2atgbjh5d.mp4?auth_key=1601173151-0-0-260509c2cb8752744f1c2b5652747ad1&bcevod_channel=searchbox_feed&pd=1&pt=3",
	"https://vd2.bdstatic.com/mda-ibtfrfq2agf2216r/hd/mda-ibtfrfq2agf2216r.mp4?v_from_s=tc_videoui_4135&auth_key=1611284615-0-0-e2902fb9f17bb70ca87e881a32a37a27&bcevod_channel=searchbox_feed&pd=1&pt=3&abtest="
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(true, animated: false)
		view.backgroundColor = UIColor.white
		
		let player = BSVideoPlayer(
			url: urls.last!,
			frame: CGRect.init(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.frame.width, height: (9.0/16.0)*view.frame.width)
		)
		view.addSubview(player)

	}
	
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

	// 状态栏隐藏控制
	override var prefersStatusBarHidden: Bool {
		if player == nil {
			return false
		}
		if !player.isPortrait {
			return true
		}
		return true
	}
	
	// 是否自动旋转
	override var shouldAutorotate: Bool {
		if player == nil {
			return true
		}
		return player.shouldAutorotate
	}
	
	// override
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		player.viewWillTransition(to: size, with: coordinator)
	}
	
//	private func loadInfoPlist() {
//		let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
//		let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path))
//		let dic = NSDictionary.init(contentsOf: URL.init(fileURLWithPath: path))
//		let flag = dic?["UIViewControllerBasedStatusBarAppearance"]
//	}
}
