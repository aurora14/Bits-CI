//
//  CellRepresentable.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 12/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import UIKit

protocol CellRepresentable: ViewRepresentable {
  
  var rowHeight: CGFloat { get }
  
  func cellInstance(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
  
}
