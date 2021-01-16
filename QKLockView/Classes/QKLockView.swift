//
//  QKLockView.swift
//  Created by Jingnan Zhang on 16/7/12.
//  Copyright © 2016年 Jingnan Zhang. All rights reserved.
//  这是手势密码的工具类

import UIKit


//  手势密码每次设置完成后的代理方法
public protocol QKLockViewDelegate: NSObjectProtocol {
    
    func lockView<T>(_ lockView:QKLockView, didEndWithPassCode passcode:T)
    
}

/** 此view最好是正方形,目前宽高比=1：1.1 */


public final class QKLockView: UIView {
    
    public weak var delegate: QKLockViewDelegate?
    private var password: String?
    
    /** 选中按钮数组 */
    private var btnAry = [UIButton]()
    
    private var selectBtnAry = [UIButton]()
    private var btnW: CGFloat = 0
    private var verticalMergin: CGFloat = 0
    private var horizonMergin: CGFloat = 0
    
    private var currentPoint: CGPoint = CGPoint.init()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.doInit()
    }
    public override  func awakeFromNib() {
        super.awakeFromNib()
        self.doInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        _ = Framework()
    }
    
    
    private func doInit() { // 宽高比 = 1：1.1
//        self.backgroundColor = UIColor.grayColor()
        btnW = UIScreen.main.bounds.size.width * 55.0 / 375.0
        horizonMergin = (UIScreen.main.bounds.size.width * 0.85 - 3 * btnW) * 0.5
        verticalMergin = ((btnW * 3 + horizonMergin * 2) * 1.1 - 3 * btnW) * 0.5
        for i in 0...8 {
            let btn:UIButton = UIButton.init(frame: CGRect(x: CGFloat(i % 3) * (btnW + horizonMergin), y: CGFloat(i/3) * (btnW + verticalMergin), width: btnW, height: btnW))
            btn.tag = i
            btn.contentMode = .scaleAspectFill
            btn.isUserInteractionEnabled = false // 禁止与用户交互
            let nImg = QKLockViewImage.cicleNormalImage
            let sImg = QKLockViewImage.cicleSelectImage
            btn.setImage(nImg, for: .normal)
            btn.setImage(sImg, for: .selected)
            self.addSubview(btn)
            
            btnAry.append(btn)
        }
        
    }
    
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPoint = ((touches as NSSet).anyObject() as! UITouch).location(in: self)
        for btn in btnAry{
            if btn.frame.contains(currentPoint) && btn.isSelected == false { // 按钮包含这个点
                btn.isSelected = true
                selectBtnAry.append(btn)
            }
        }
        self.setNeedsDisplay()
        
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var passStr:String = ""
        for btn in selectBtnAry {
            // 按钮的图片复原
            btn.isSelected = false
            passStr = passStr.appendingFormat("%d", btn.tag)
        }
        // 执行代理的方法,selectBtnAry.count != 0,防止了点击别处就触发代理的方法
        if (delegate != nil) && selectBtnAry.count != 0{
                delegate?.lockView(self, didEndWithPassCode: passStr)
        }
        selectBtnAry.removeAll()
        self.setNeedsDisplay()
        
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectBtnAry.removeAll()
        self.setNeedsDisplay()
    }
    
    /**
      * 绘图
     */
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        let beziPath = UIBezierPath.init() // 必须重置
        
        if selectBtnAry.count == 0 {
            return
        }else{
            for i in 0...selectBtnAry.count-1 {
                if 1 == selectBtnAry.count {
                    beziPath.move(to: selectBtnAry[i].center)
                    beziPath.addLine(to: currentPoint)
                    
                }else{
                    if i == selectBtnAry.count - 1 {
                        beziPath.move(to: selectBtnAry[i].center)
                        beziPath.addLine(to: currentPoint)
                    }else{
                        beziPath.move(to: selectBtnAry[i].center)
                        beziPath.addLine(to: selectBtnAry[i+1].center)
                    }
                    
                }
            
            }
        }
        beziPath.lineWidth = 8
        beziPath.lineJoinStyle = .round
        UIColor.orange.setStroke()
        beziPath.stroke()
    }
    
}


