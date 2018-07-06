//
//  EMNavigationBarStyle.swift
//  emarketing-ios
//
//  Created by jiafeng wu on 2018/7/4.
//  Copyright © 2018年 jiafeng wu. All rights reserved.
//

import UIKit

/// 优化 NavigationController 转场的基类
public class EMViewController: UIViewController {
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let color = navBarTitleColor
        navBarTitleColor = color
    }
}

// MARK: - UIViewController
extension EMViewController {
    
    private struct DefaultValue {
        static var navBarBgAlpha: CGFloat = 1.0
        static var navBarBgColor: UIColor = .white
        static var navBarTintColor: UIColor = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1.0)
        static var navBarTitleColor: UIColor = .black
        static var statusBarStyle: UIStatusBarStyle = .default
        static var isHiddenShadowImage: Bool = false
    }
    
    public var emNavigationController: EMNavigationController? {
        return self.navigationController as? EMNavigationController
    }
    
    /// 设置导航栏背景透明度
    public var navBarBgAlpha: CGFloat {
        get {
            if let alpha = objc_getAssociatedObject(self, &DefaultValue.navBarBgAlpha) as? CGFloat {
                return alpha
            }
            return DefaultValue.navBarBgAlpha
        }
        set {
            let alpha = max(min(newValue, 1), 0)
            objc_setAssociatedObject(self, &DefaultValue.navBarBgAlpha, alpha, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //设置导航栏透明度
            emNavigationController?.navBarBackgroundAlpha(alpha)
        }
    }
    
    /// 设置导航栏的背景颜色
    public var navBarBgColor: UIColor {
        get {
            if let color = objc_getAssociatedObject(self, &DefaultValue.navBarBgColor) as? UIColor {
                return color
            }
            return DefaultValue.navBarBgColor
        }
        set {
            objc_setAssociatedObject(self, &DefaultValue.navBarBgColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            emNavigationController?.navBarBackgroundColor(newValue)
        }
    }
    
    /// 设置 tint color
    public var navBarTintColor: UIColor {
        get {
            if let color = objc_getAssociatedObject(self, &DefaultValue.navBarTintColor) as? UIColor {
                return color
            }
            return DefaultValue.navBarTintColor
        }
        set {
            objc_setAssociatedObject(self, &DefaultValue.navBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            emNavigationController?.navBarTintColor(newValue)
        }
    }
    
    /// 设置 title 的颜色
    public var navBarTitleColor: UIColor {
        get {
            if let color = objc_getAssociatedObject(self, &DefaultValue.navBarTitleColor) as? UIColor {
                return color
            }
            return DefaultValue.navBarTitleColor
        }
        set {
            objc_setAssociatedObject(self, &DefaultValue.navBarTitleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            emNavigationController?.navBarTitleColor(newValue)
        }
    }
    
    /// 设置 status bar 的状态
    public var statusBarStyle: UIStatusBarStyle {
        get {
            if let style = objc_getAssociatedObject(self, &DefaultValue.statusBarStyle) as? UIStatusBarStyle {
                return style
            }
            return DefaultValue.statusBarStyle
        }
        set {
            objc_setAssociatedObject(self, &DefaultValue.statusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// 隐藏或显示分割线
    public var isHiddenShadowImage: Bool {
        get {
            if let isHide = objc_getAssociatedObject(self, &DefaultValue.isHiddenShadowImage) as? Bool {
                return isHide
            }
            return DefaultValue.isHiddenShadowImage
        }
        set {
            objc_setAssociatedObject(self, &DefaultValue.isHiddenShadowImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            emNavigationController?.shadowImageHide(newValue)
        }
    }
}

/// 优化转场效果的 navigationcontroller
public class EMNavigationController: UINavigationController, SelfAware {
    
    var emNavigationBar: EMNavigationBar? {
        return self.navigationBar as? EMNavigationBar
    }
}

// MARK: - UINavigationController Swizzle Function
extension EMNavigationController {
    
    /// 设置 status bar style
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return (topViewController as? EMViewController)?.statusBarStyle ?? .default
    }
    
    static func awake() {
        /// 判断是否是其子类
        guard self !== UINavigationController.self else { return }
        self.swizzle
    }
    
    /**
     * Swift 中 static let 具备 dispatch once 特性，所以可以用这种方式声明，
     * 闭包的形式声明一个代码块，默认是懒加载
     * 类似于 Objective-c 中的 dispatch once
     */
    private static let swizzle: () = {
        print("UINavigationController swizzle")
        let needSwizzleSelectorAry = [
            NSSelectorFromString("_updateInteractiveTransition:"),
            #selector(popToViewController(_:animated:)),
            #selector(popToRootViewController(animated:))
        ]
        let swizzleSelectorAry = [
            #selector(em_updateInteractiveTransition(_:)),
            #selector(em_popToViewController(_:animated:)),
            #selector(em_popToRootViewControllerAnimated(_:))
        ]
        for sel in needSwizzleSelectorAry {
            let str = ("em_" + sel.description).replacingOccurrences(of: "__", with: "_")
            if let originMethod = class_getInstanceMethod(EMNavigationController.self, sel),
                let swizzleMethod = class_getInstanceMethod(EMNavigationController.self, Selector(str)) {
                
                method_exchangeImplementations(originMethod, swizzleMethod)
            }
        }
    }()
    
    /// 用于替换系统的 _updateInteractiveTransition: 方法，监听返回手势进度
    @objc func em_updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard self.isKind(of: EMNavigationController.self) else { return }
        let topVC = self.topViewController
        /// transitionCoordinator 带有两个 VC 的转场上下文
        if let coor = topVC?.transitionCoordinator,
            let fromVC = coor.viewController(forKey: .from) as? EMViewController,
            let toVC = coor.viewController(forKey: .to) as? EMViewController {
            
            let fromAlpha = fromVC.navBarBgAlpha
            let toAlpha = toVC.navBarBgAlpha
            let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete
            self.navBarBackgroundAlpha(nowAlpha)
            
            let fromTintColor = fromVC.navBarTintColor
            let toTintColor = toVC.navBarTintColor
            let nowTintColor = averageColor(fromColor: fromTintColor, toColor: toTintColor, percent: percentComplete)
            self.navBarTintColor(nowTintColor)
            
            let fromColor = fromVC.navBarBgColor
            let toColor = toVC.navBarBgColor
            let nowColor = averageColor(fromColor: fromColor, toColor: toColor, percent: percentComplete)
            self.navBarBackgroundColor(nowColor)
        }
        em_updateInteractiveTransition(percentComplete)
    }
    
    /// 替换系统的 pop
    @objc func em_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let vc = viewController as? EMViewController {
            updateAllStyle(vc)
            navBarTitleColor(vc.navBarTitleColor)
        }
        return em_popToViewController(viewController, animated: animated)
    }
    
    /// 替换系统的 pop to root
    @objc func em_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        if let vc = viewControllers.first as? EMViewController {
            updateAllStyle(vc)
            navBarTitleColor(vc.navBarTitleColor)
        }
        return em_popToRootViewControllerAnimated(animated)
    }
}

// MARK: - UINavigationController Customize Function
extension EMNavigationController {
    
    /// 设置透明度
    fileprivate func navBarBackgroundAlpha(_ alpha: CGFloat) {
        emNavigationBar?.backgroundAlpha(alpha)
    }
    
    /// 设置背景色
    fileprivate func navBarBackgroundColor(_ color: UIColor) {
        emNavigationBar?.backgroundColor(color)
    }
    
    /// 设置 Tint color
    fileprivate func navBarTintColor(_ color: UIColor) {
        emNavigationBar?.tintColor(color)
    }
    
    /// 设置 title 的颜色
    fileprivate func navBarTitleColor(_ color: UIColor) {
        emNavigationBar?.titleColor(color)
    }
    
    /// 隐藏或显示分割线
    fileprivate func shadowImageHide(_ hide: Bool) {
        emNavigationBar?.shadowImage(hide)
    }
    
    private func updateAllStyle(_ viewController: EMViewController) {
        guard self.isKind(of: EMNavigationController.self) else { return }
        navBarBackgroundAlpha(viewController.navBarBgAlpha)
        navBarBackgroundColor(viewController.navBarBgColor)
        navBarTintColor(viewController.navBarTintColor)
        shadowImageHide(viewController.isHiddenShadowImage)
    }
    
    // 计算颜色的过度
    private func averageColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let nowRed = fromRed + (toRed - fromRed) * percent
        let nowGreen = fromGreen + (toGreen - fromGreen) * percent
        let nowBlue = fromBlue + (toBlue - fromBlue) * percent
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        
        return UIColor(red: nowRed, green: nowGreen, blue: nowBlue, alpha: nowAlpha)
    }
}

// MARK: - UINavigationBarDelegate
extension EMNavigationController: UINavigationBarDelegate {
    
    /// pop
    public func navigationBar(_ navigationBar: UINavigationBar,
                              shouldPop item: UINavigationItem) -> Bool {
        
        if let topVC = topViewController,
            let coor = topVC.transitionCoordinator,
            coor.initiallyInteractive {
            
            if #available(iOS 10.0, *) {
                coor.notifyWhenInteractionChanges({ (context) in
                    self.dealInteractionChanges(context)
                })
            } else {
                coor.notifyWhenInteractionEnds({ (context) in
                    self.dealInteractionChanges(context)
                })
            }
            return true
        }
        
        let itemCount = navigationBar.items?.count ?? 0
        let n = viewControllers.count >= itemCount ? 2 : 1
        let popToVC = viewControllers[viewControllers.count - n]
        
        popToViewController(popToVC, animated: true)
        return true
    }
    
    /// push 到一个新的页面
    public func navigationBar(_ navigationBar: UINavigationBar,
                              shouldPush item: UINavigationItem) -> Bool {
        
        if let vc = topViewController as? EMViewController {
            updateAllStyle(vc)
        }
        return true
    }
    
    /// 处理返回手势中断的情况
    private func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        /// 设置动画
        let animations: (UITransitionContextViewControllerKey) -> () = { [weak self] in
            if let vc = context.viewController(forKey: $0) as? EMViewController {
                self?.updateAllStyle(vc)
            }
        }
        
        if context.isCancelled {
            /// 手势取消
            let cancelDuration: TimeInterval = context.transitionDuration * Double(context.percentComplete)
            UIView.animate(withDuration: cancelDuration) {
                animations(.from)
            }
        } else {
            /// 手势完成
            let finishDuration: TimeInterval = context.transitionDuration * Double(1 - context.percentComplete)
            UIView.animate(withDuration: finishDuration) {
                animations(.to)
            }
        }
    }
}

/// 优化转场效果的 navigationbar
class EMNavigationBar: UINavigationBar {}

// MARK: - UINavigationBar
extension EMNavigationBar {
    
    fileprivate struct DefaultValue {
        static var backgroundView: UIView = UIView()
        static var backgroundImageView: UIImageView = UIImageView()
        static var statusBarStyle: UIStatusBarStyle = .default
    }
    
    /// 导航栏背景视图
    fileprivate var backgroundView: UIView? {
        get {
            guard let bgView = objc_getAssociatedObject(self, &DefaultValue.backgroundView) as? UIView else {
                return nil
            }
            return bgView
        }
        set {
            objc_setAssociatedObject(self, &DefaultValue.backgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 设置导航栏的透明度
    fileprivate func backgroundAlpha(_ alpha: CGFloat) {
        
        if let barBackgroundView = subviews.first {
            if #available(iOS 11.0, *) {
                for view in barBackgroundView.subviews
                    where !view.isKind(of: UIImageView.self) {
                        
                        view.alpha = alpha
                }
            } else {
                barBackgroundView.alpha = alpha
            }
        }
    }
    
    /// 设置导航栏背景色
    fileprivate func backgroundColor(_ color: UIColor) {
        
        if backgroundView == nil {
            // 添加一个透明背景的 image 到 _UIBarBackground
            setBackgroundImage(UIImage(), for: .default)
            let height = DeviceInfo.deviceName == .iPhoneX ? 64 : 88
            backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: Int(bounds.width), height: height))
            backgroundView?.autoresizingMask = .flexibleWidth
            // _UIBarBackground 是 navigationBar 的第一个子视图
            subviews.first?.insertSubview(backgroundView ?? UIView(), at: 0)
        }
        backgroundView?.backgroundColor = color
    }
    
    /// 设置 tint color
    fileprivate func tintColor(_ color: UIColor) {
        tintColor = color
    }
    
    /// 设置 title 的颜色
    fileprivate func titleColor(_ color: UIColor) {
        guard titleTextAttributes != nil else {
            titleTextAttributes = [.foregroundColor: color]
            return
        }
        titleTextAttributes?.updateValue(color, forKey: .foregroundColor)
    }
    
    /// 隐藏或显示分割线
    fileprivate func shadowImage(_ hide: Bool) {
        shadowImage = hide ? UIImage() : nil
    }
}

/**
 * 替代 objective-c 中的 +load() 方法
 * 替代 Swift 之前版本中的 initialize() 方法
 * 通过 runtime 获取到所有类的列表，
 * 然后向所有遵循 SelfAware 协议的类发送消息，并且把这些操作放到 UIApplication 的 next 属性的调用中，
 * 同时 next 属性会在 applicationDidFinishLaunching 之前被调用。
 */
private protocol SelfAware: class {
    static func awake()
}

private class NothingToSeeHere {
    
    static func harmlessFunction() {
        
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0..<typeCount { (types[index] as? SelfAware.Type)?.awake() }
        types.deallocate()
    }
}

extension UIApplication {
    
    /// 启动只执行一次
    private static let runOnce: Void = {
        NothingToSeeHere.harmlessFunction()
    }()
    
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
}
