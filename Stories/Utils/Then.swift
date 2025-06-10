//
//  Then.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import Foundation

protocol Then { }

extension Then where Self: AnyObject {
  func then(_ mutation: (Self) -> Void) -> Self {
    mutation(self)
    return self
  }
}

extension NSObject: Then { }
