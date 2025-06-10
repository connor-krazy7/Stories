//
//  Collection+subscript.swift
//  Stories
//
//  Created by Artsem Hotsau on 1.04.25.
//

import Foundation

extension Collection {
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
