<!--
 * @Author: your name
 * @Date: 2021-01-22 11:29:05
 * @LastEditTime: 2021-01-22 14:27:05
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit◊
 * @FilePath: /shaobin/Blog/BSPlayer.md
-->
## [BSPlayer]()
一个由AVPlayer开发的视频播放器，支持旋转全屏，速度控制，调节播放进度，还可以自己自定义UI。
## 使用
1. 基本使用
```
let player = BSVideoPlayer(
		url: urls.last!,
		frame: CGRect.init(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.frame.width, height: (9.0/16.0)*view.frame.width)
	)
view.addSubview(player)
```
2. 旋转
```
是否自动旋转
override var shouldAutorotate: Bool {
    if player == nil {
        return true
    }
    return player.shouldAutorotate
}
```
重写controller的tanstion方法
```
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    player.viewWillTransition(to: size, with: coordinator)
}
```
3. 状态栏隐藏控制
```
override var prefersStatusBarHidden: Bool {
    if player == nil {
        return false
    }
    if !player.isPortrait {
        return true
    }
    return true
}
```

4. 播放器的一些代理方法
```
// 点击返回按钮
func playerViewClickBack(playerView: BSVideoPlayer) {}

// 播放器将要旋转
func playerView(playerView: BSVideoPlayer, shouldRotateTo orientation: UIInterfaceOrientation) {}

// 播放器已经完成旋转
func playerView(playerView: BSVideoPlayer, didRotateTo orienttation: UIInterfaceOrientation) {}

// 控制视图将要隐藏
func playerView(playerView: BSVideoPlayer, controllViewWillFade state: Int) {}

// 控制视图已经隐藏
func playerView(playerView: BSVideoPlayer, controllViewDidFade state: Int) {}
```
详细使用请查看项目中的代码

## 安装
### Cocoapods
1. 在Podfile文件中添加`pod 'BSPlayer'`
2. 运行 `pod install` 或者 `pod update`
3. 导入 `import BSPlayer`

### 手动
1. 下载项目
2. 直接把Class文件夹拉到项目中

