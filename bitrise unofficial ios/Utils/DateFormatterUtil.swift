//
//  DateFormatterUtil.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 23/6/18.
//  Copyright © 2018 Alexei Gudimenko. All rights reserved.
//

import Foundation

let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  return formatter
}()
