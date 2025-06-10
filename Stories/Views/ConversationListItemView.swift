//
//  ConversationListItemView.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import SwiftUI

struct ConversationListItemViewModel: Identifiable, Hashable {
  struct LastMessage: Hashable {
    let date: Date
    let text: String
  }
  
  let conversationId: String
  let conversationName: String
  let iconURL: URL?
  let lastMessage: LastMessage?
  
  var id: String { conversationId }
  
  var lastMessageText: String {
    lastMessage.map(\.text).or("No messages")
  }
  
  var lastMessageDate: String? {
    lastMessage.map(\.date).map(DateFormatter.conversationLastMessageFormatter.string(from:))
  }
}

struct ConversationListItemView: View {
  let model: ConversationListItemViewModel
  
  var body: some View {
    HStack {
      ComponentImageView(url: model.iconURL)
        .clipShape(Circle())
        .aspectRatio(1, contentMode: .fit)
        .padding(.vertical, 5)
      VStack(alignment: .leading) {
        HStack {
          Text(model.conversationName)
            .fontWeight(.bold)
          Spacer()
          if let lastMessageDate = model.lastMessageDate {
            Text(lastMessageDate)
              .fontWeight(.light)
          }
        }
        Text(model.lastMessageText)
          .fontWeight(.light)
      }
    }
  }
}
