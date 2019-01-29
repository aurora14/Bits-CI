//
//  DummyProjectVM.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 6/11/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit
import SkeletonView

/// A version of the project view model to be shown when the app is fetching the initial information.
/// It shows a skeleton view over the standard cell content.
class DummyProjectViewModel: BitriseProjectViewModel {
  
  init() {
    super.init(with: BitriseApp())
  }
  
  override func cellInstance(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView
      .dequeueReusableCell(withIdentifier: CellReuseIdentifier.projectCell) as? ProjectCell else {
        return UITableViewCell(style: .default, reuseIdentifier: CellReuseIdentifier.projectCell)
    }
    
    // Since this is just a dummy VM that's intended to show a 'loading' skeleton view, we can skip
    // the normal call to cell.setup(with:) and handle all the presentation here.
    DispatchQueue.main.async {
      cell.projectIconImageView.showAnimatedGradientSkeleton()
      cell.buildStatusStrip.showAnimatedGradientSkeleton()
      cell.projectNameLabel.showAnimatedGradientSkeleton()
      cell.projectOwnerLabel.showAnimatedGradientSkeleton()
      cell.buildNumberLabel.showAnimatedGradientSkeleton()
      cell.timeElapsedSinceLastBuildLabel.showAnimatedGradientSkeleton()
      cell.buildStatusImageView.showAnimatedGradientSkeleton()
    }
    
    return cell
  }
}
