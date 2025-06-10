//
//  StoriesApp.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import SwiftUI

@main
struct StoriesApp: App {
    var body: some Scene {
        WindowGroup {
          ConversationsView(model: ConversationsViewModel())
        }
    }
}
