//
//  Logger.swift
//  bitrise unofficial ios
//
//  Created by Alexei Gudimenko on 9/1/20.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Tony Arnold (@tonyarnold)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import os.log

public class Logger {
  public struct Categorization {
    let subsystem: String
    let category: String
  }

  private let log: OSLog

  public required init(categorization: Categorization? = nil) {
    #if DEBUG
    if let categorization = categorization {
      log = OSLog(subsystem: categorization.subsystem, category: categorization.category)
    } else {
      log = OSLog.default
    }
    #else
    log = OSLog.disabled
    #endif
  }

  private func custom(type: OSLogType, message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line) {
    os_log("%@.%@:%d - %@", log: log, type: type, fileNameWithoutSuffix(file), function, line, "\(message())")
  }

  public func `default`(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    custom(type: .default, message: message(), file: file, function: function, line: line)
  }

  public func debug(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    custom(type: .debug, message: message(), file: file, function: function, line: line)
  }

  public func info(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    custom(type: .info, message: message(), file: file, function: function, line: line)
  }

  public func error(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    custom(type: .error, message: message(), file: file, function: function, line: line)
  }

  public func fault(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
    custom(type: .fault, message: message(), file: file, function: function, line: line)
  }

  /// returns the filename of a path
  private func fileNameOfFile(_ file: String) -> String {
    let fileParts = file.components(separatedBy: "/")
    if let lastPart = fileParts.last {
      return lastPart
    }
    return ""
  }

  /// returns the filename without suffix (= file ending) of a path
  private func fileNameWithoutSuffix(_ file: String) -> String {
    let fileName = fileNameOfFile(file)

    if !fileName.isEmpty {
      let fileNameParts = fileName.components(separatedBy: ".")
      if let firstPart = fileNameParts.first {
        return firstPart
      }
    }
    return ""
  }
}
