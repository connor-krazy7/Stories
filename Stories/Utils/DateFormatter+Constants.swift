//
//  DateFormatter+Constants.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import Foundation

extension DateFormatter {
  static let conversationLastMessageFormatter = DateFormatter().then {
    $0.dateFormat = "HH:mm MMM dd"
  }
}
