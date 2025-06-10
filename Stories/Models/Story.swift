//
//  Story.swift
//  Stories
//
//  Created by Artsem Hotsau on 5.04.25.
//

import Foundation

struct Story: Identifiable, Hashable {
  var id: String { storyId }
  
  let storyId: String
  let authorId: String
  let authorName: String
  let imageURL: URL?
}
