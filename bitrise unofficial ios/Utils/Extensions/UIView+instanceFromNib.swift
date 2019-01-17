//
//  UIView+instanceFromNib.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 16/1/19.
//  Copyright © 2019 Alexei Gudimenko. All rights reserved.
//

import UIKit


extension UIView {
  
  
  /// A convenience function that lets you generate an instance of UIView from a
  /// corresponding NIB file.
  ///
  /// - Parameter identifier: A case-sensitive string identifier of the .xib file you wish to use
  /// - Returns: generic UIView if successfully instantiated, nil if there was an error.
  ///
  /// The function returns a UIView instance to the caller. If there are no further view updates to
  /// be made, the returned object can be used as-is. If a particular subclass is required, the
  /// returned object should be cast to the desired UIView subclass.
  ///
  /// e.g
  /// ````
  /// let defaultView = UIView.instanceFrom(nib: "MyCustomView")
  /// let customView = UIView.instanceFrom(nib: "MyCustomView") as? MyCustomView
  
  class func instanceFrom(nib identifier: String) -> UIView? {
    
    guard let view = UINib(nibName: identifier, bundle: nil)
      .instantiate(withOwner: nil, options: nil)[0] as? UIView else {
        assertionFailure("Couldn't instantiate view from specified NIB file." +
          "Check that you specified the correct identifier and that the NIB file exists in your project")
        return nil
    }
    
    return view
  }
  
  
  /// Creates a view instance from a corresponding XIB/NIB file.
  ///
  /// - Parameter forViewType: Subclass of UIView that you wish to instantiate
  /// - Returns: Instance of the custom UIView subclass if successful, or nil on error
  class func instanceFromNib<T>(forViewType: T.Type) -> T? where T: UIView {
    
    let identifier = String(describing: T.self)
    
    // [0] indicates the 'parent' view, which by design includes the rest of the subviews
    // that represent the layout.
    guard let view = UINib(nibName: identifier, bundle: nil)
      .instantiate(withOwner: nil, options: nil)[0] as? T else {
        assertionFailure("Couldn't instantiate view from specified NIB file." +
          "Check that the class you're using is a valid UIView subclass and that the NIB file" +
          "exists in your project")
        return nil
    }
    
    return view
  }
}
