//
//  BSPlayerSpeedView.swift
//  BSBSPlayer
//
//  Created by 未可知 on 2020/10/13.
//

import Foundation
import UIKit

public struct SpeedViewModel {
	var desc: String
	var speed: Float
	var isSelected: Bool
}

public class BSPlayerSpeedView: UIView, UITableViewDelegate, UITableViewDataSource {
	
	private var tableView: UITableView
	private var datas: [SpeedViewModel]
	
	var didSelectedSpeed: ((_ speed: SpeedViewModel) -> Void)?
	
	init(frame: CGRect, datas: [SpeedViewModel]) {
		var w = frame.width - 10
		if #available(iOS 11.0, *) {
			w = w - (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft ? UIApplication.shared.keyWindow!.safeAreaInsets.right : UIApplication.shared.keyWindow!.safeAreaInsets.left)
		}
		tableView = UITableView.init(frame: CGRect.init(x: 5, y: 10, width: w, height: frame.height - 20), style: .plain)
		self.datas = datas
		super.init(frame: frame)
		backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)

		if #available(iOS 11.0, *) {
			tableView.contentInsetAdjustmentBehavior = .never
		}
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(BSPlayerSpeedCell.classForCoder(), forCellReuseIdentifier: "BSPlayerSpeedCell")
		tableView.rowHeight = max(tableView.frame.width, tableView.frame.height)/CGFloat(datas.count)
		tableView.backgroundColor = UIColor.clear
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		addSubview(tableView)
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	func show() {
		self.isHidden = false
		UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions.curveEaseOut) {
			if #available(iOS 11.0, *) {
				self.transform = CGAffineTransform.init(translationX: -self.width-(UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft ? UIApplication.shared.keyWindow!.safeAreaInsets.right : UIApplication.shared.keyWindow!.safeAreaInsets.left), y: 0)
			}
			else {
				self.transform = CGAffineTransform.init(translationX: -self.width, y: 0)
			}
		} completion: { (f) in
			PlayerLoger.info(log: "\(self.frame)")
		}
	}
	
	func dismiss() {
		UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions.curveEaseOut) {
			self.transform = CGAffineTransform.identity
		} completion: { (f) in
			self.isHidden = true
		}
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return datas.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BSPlayerSpeedCell") as! BSPlayerSpeedCell
		cell.model = datas[indexPath.row]
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var i = 0
		while i < datas.count {
			datas[i].isSelected = false
			i+=1
		}
		var model = datas[indexPath.row]
		model.isSelected = true
		datas.remove(at: indexPath.row)
		datas.insert(model, at: indexPath.row)
		tableView.reloadData()
		didSelectedSpeed?(model)
	}
	
}

class BSPlayerSpeedCell: UITableViewCell {
	
	var contentLabel: UILabel
	var model: SpeedViewModel? {
		didSet {
			contentLabel.text = model!.desc
			contentLabel.textColor = model!.isSelected ? UIColor.orange : UIColor.white
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		contentLabel = UILabel.init()
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		backgroundColor = UIColor.clear
//		contentLabel.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
		contentLabel.textAlignment = .center
		contentView.addSubview(contentLabel)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let x: CGFloat = 2.5
		let y: CGFloat = 2.5
		let w: CGFloat = width - x*2
		let h: CGFloat = height - y*2
		contentLabel.frame = CGRect.init(x: x, y: y, width: w, height: h)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
