//
//  UIViewController+InteractiveGestures.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 25/9/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

private protocol SwipeNavigationConfigurable: UIGestureRecognizerDelegate {
  func setupSwipeToGoBack(withPopGestureRecognizerEnabled value: Bool, consumesGesture consumeSwitch: Bool)
}

extension UIViewController: SwipeNavigationConfigurable {
  
  /// The default implementation of this method looks for the containing Navigation Controller;
  /// if one is found, it sets the `isEnabled` property of the Navigation Controller's Interactive
  /// Pop Gesture Recognizer. Set this property to `true` if you want to enable swipe-to-go-back
  /// navigation in your view controller.
  ///
  /// - Parameters:
  ///   - value: Boolean that determines whether the recognizer is enabled or not. Default
  ///     for this property is `false`, which means the swipe gesture is "off" unless the user
  ///     sets it explicitly to "on"
  ///   - consumeSwitch: whether the recognizer should also consume the touch gesture or make it
  ///     available to other views. The default value is `true`, which means the touch gesture
  ///     will be consumed unless the user makes it explicitly available to other views. 
  func setupSwipeToGoBack(withPopGestureRecognizerEnabled value: Bool = false,
                          consumesGesture consumeSwitch: Bool = true) {
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    navigationController?.interactivePopGestureRecognizer?.isEnabled = value
    navigationController?.interactivePopGestureRecognizer?.cancelsTouchesInView = consumeSwitch
  }
  
}
