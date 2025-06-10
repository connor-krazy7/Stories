//
//  ContentView.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import SwiftUI

struct StretchyHeaderView: View {
    var body: some View {
        ScrollView {
          GeometryReader { geometry in
            let offsetY = geometry.frame(in: .global).minY
            let height = max(300 + offsetY, 0)
            
            Text("ABC")
              .frame(
                width: geometry.size.width,
                height: height
              )
              .position(
                x: geometry.size.width / 2,
                y: 300 / 2 - offsetY / 2
              )
              .overlay {
                Rectangle()
                  .fill(.clear)
                  .stroke(.blue, lineWidth: 10)
              }
            }
            .frame(height: 300)
            .overlay {
              Rectangle()
                .fill(.clear)
                .stroke(.red, lineWidth: 5)
            }

            VStack(alignment: .leading, spacing: 20) {
                ForEach(0..<20) { i in
                    Text("Item \(i)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct StretchyHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        StretchyHeaderView()
    }
}
