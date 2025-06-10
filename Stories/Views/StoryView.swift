//
//  StoryView.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import SwiftUI

struct StoryView: View {
  enum BorderStyle: Hashable {
    case notSeenStory
    case seenStory
  }
  
  struct Model: Hashable, Identifiable {
    var id: String { storyId }
    
    let storyId: String
    let imageURL: URL?
  }
  
  let model: Model
  var borderStyle: BorderStyle =  DefaultValue.borderStyle
  var borderWidth: CGFloat = DefaultValue.borderWidth
  var borderPadding: CGFloat = DefaultValue.borderPadding
  
  private var borderGradient: Gradient {
    switch borderStyle {
    case .notSeenStory: Gradient(colors: [.cyan, .purple])
    case .seenStory: Gradient(colors: [.gray])
    }
  }
  
  var body: some View {
    ZStack {
      Circle()
        .fill(Color.clear)
        .stroke(borderGradient, lineWidth: borderWidth)
        .padding(borderWidth / 2)
      ComponentImageView(url: model.imageURL)
        .clipShape(Circle())
        .padding(borderWidth + borderPadding)
    }
    .aspectRatio(1, contentMode: .fit)
  }
}

// MARK: - Modify

extension StoryView {
  func storyBorderStyle(_ borderStyle: StoryView.BorderStyle?) -> StoryView {
    StoryView(model: model, borderStyle: borderStyle.or(DefaultValue.borderStyle), borderWidth: borderWidth, borderPadding: borderPadding)
  }
  
  func storyBorderWidth(_ borderWidth: CGFloat?) -> StoryView {
    StoryView(model: model, borderStyle: borderStyle, borderWidth: borderWidth.or(DefaultValue.borderWidth), borderPadding: borderPadding)
  }
  
  func storyBorderPadding(_ borderPadding: CGFloat?) -> StoryView {
    StoryView(model: model, borderStyle: borderStyle, borderWidth: borderWidth, borderPadding: borderPadding.or(DefaultValue.borderPadding))
  }
}

// MARK: - Constants

private extension StoryView {
  enum DefaultValue {
    static var borderStyle: BorderStyle { .notSeenStory }
    static var borderWidth: CGFloat { 0 }
    static var borderPadding: CGFloat { 0 }
  }
}

// MARK: - Preview

#Preview() {
  StoryView(model: StoryView.Model(storyId: "story_0", imageURL: URL(string: "https://picsum.photos/id/234/100")))
    .storyBorderStyle(.notSeenStory)
    .storyBorderWidth(3)
    .storyBorderPadding(1)
    .frame(height: 40)
//    .scaleEffect(x: 8, y: 8)
}
