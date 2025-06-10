//
//  Strings+Interpolation.swift
//  Stories
//
//  Created by Artsem Hotsau on 31.03.25.
//

import Foundation

extension String.StringInterpolation {
  mutating func appendInterpolation<T>(unwrapping value: T?) {
    if let value {
      appendInterpolation(value)
    } else {
      appendInterpolation("nil")
    }
  }
}
