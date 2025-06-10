//
//  Optional+Or.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import Foundation

extension Optional {
  func or(_ fallbackValue: @autoclosure () -> Wrapped) -> Wrapped {
    self ?? fallbackValue()
  }
  
  func or(_ fallbackValue: @autoclosure () -> Wrapped?) -> Wrapped? {
    self ?? fallbackValue()
  }
}

extension Optional where Wrapped: ExpressibleByArrayLiteral {
  var orEmpty: Wrapped {
    self.or([])
  }
}

extension Optional where Wrapped: ExpressibleByDictionaryLiteral {
  var orEmpty: Wrapped {
    self.or([:])
  }
}
