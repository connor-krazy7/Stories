//
//  ComponentImageView.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import SwiftUI
import Kingfisher

struct ComponentImageView: View {
  @State
  var url: URL?
  
  var body: some View {
    // Only in favour of images caches
    KFImage(url)
      .placeholder { Color.gray }
      .resizable()
  }
}
