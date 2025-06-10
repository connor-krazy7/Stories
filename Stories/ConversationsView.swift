//
//  ConversationsView.swift
//  Stories
//
//  Created by Artsem Hotsau on 30.03.25.
//

import SwiftUI

@MainActor
@Observable
class ConversationsViewModel: Sendable {
  struct DebugConfig: Equatable, Sendable {
    var storiesCount = 20
    var visibleMiniStoriesCount = 3
    var conversationsCount = 30
    var demistifyTransitions = false
    var useListAsScrollingContainer = true
  }
  
  var debugConfig = DebugConfig() {
    didSet { debugConfigChanged(debugConfig, oldValue: oldValue) }
  }
  
  private(set) var stories: [Story] = []
  private(set) var miniStories: [Story] = []
  private(set) var conversations: [ConversationListItemViewModel] = []
  
  @ObservationIgnored
  lazy var leadingVisibleStoryId = stories.first?.storyId

  func reloadData() {
    stories = (0..<debugConfig.storiesCount).map(MocksFactory.story(seed:))
    miniStories = Array(stories.prefix(debugConfig.visibleMiniStoriesCount))
    conversations = (0..<debugConfig.conversationsCount).map(MocksFactory.conversation(seed:))
  }
  
  private func debugConfigChanged(_ debugConfig: DebugConfig, oldValue: DebugConfig) {
    let storiesChanged = debugConfig.storiesCount != oldValue.storiesCount
    let miniStoriesChanged = storiesChanged || debugConfig.visibleMiniStoriesCount != oldValue.visibleMiniStoriesCount
    let conversationsChanged = debugConfig.conversationsCount != oldValue.conversationsCount
    let listContainerChanged = debugConfig.useListAsScrollingContainer != oldValue.useListAsScrollingContainer
    
    if storiesChanged {
      stories = (0..<debugConfig.storiesCount).map(MocksFactory.story(seed:))
    }
    if miniStoriesChanged {
      miniStories = Array(stories.prefix(debugConfig.visibleMiniStoriesCount))
    }
    if conversationsChanged {
      conversations = (0..<debugConfig.conversationsCount).map(MocksFactory.conversation(seed:))
    }
    if listContainerChanged {
      leadingVisibleStoryId = stories.first?.storyId
    }
  }
  
  private enum MocksFactory {
    static func imageURL(seed: Int) -> URL? {
      URL(string: "https://picsum.photos/id/\(seed)/100")
    }
    
    static func story(seed: Int) -> Story {
      Story(
        storyId: "story_\(seed)",
        authorId: "author_\(seed)",
        authorName: "Author \(seed)",
        imageURL: imageURL(seed: 300 + seed)
      )
    }
    
    static func conversation(seed: Int) -> ConversationListItemViewModel {
      ConversationListItemViewModel(
        conversationId: "conversation_\(seed)",
        conversationName: "Conversation \(seed)",
        iconURL: imageURL(seed: 400 + seed),
        lastMessage: nil
      )
    }
  }
}

struct ConversationsView: View {
  private struct ListScrollOffset: Hashable {
    let initial: CGPoint
    var current: CGPoint
    var deltaY: CGFloat { initial.y - current.y }
  }
  
  private enum ViewState: Hashable {
    case stories
    case miniStories(transitionToProgress: CGFloat)
  }
  
  @Namespace
  private var namespace
  @State
  private var listScrollOffset: ListScrollOffset?
  @State
  private var viewState: ViewState = .stories
  @State
  private var isDebugSheetPresented = false
  
  let model: ConversationsViewModel
  
  var body: some View {
    VStack(spacing: 0) {
      chatsHeader
      
      if model.debugConfig.useListAsScrollingContainer {
        List {
          conversationsHeaderStories
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
          
          conversations
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .padding(.horizontal, 10)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
      } else {
        ScrollView(.vertical) {
          VStack(spacing: 0) {
            conversationsHeaderStories
            
            conversations
              .padding(.horizontal, 10)
          }
          .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .scrollTargetBehavior(.viewAligned)
      }
    }
    .background(.appGray)
    .sensoryFeedback(.selection, trigger: viewState) {
      switch ($0, $1) {
      case (.stories, .miniStories), (.miniStories, .stories): true
      default: false
      }
    }
    .overlay(debugButton)
    .sheet(isPresented: $isDebugSheetPresented) { debugView }
    .task { model.reloadData() }
  }
}

// MARK: - Subviews

private extension ConversationsView {
  func chatsHeaderStories(
    miniStories: [Story],
    stories: [Story],
    leadingVisibleStoryId: String?,
    visibilityProgress: CGFloat
  ) -> some View {
    let storiesStartingFromLeadingVisible = stories
      .firstIndex { $0.storyId == leadingVisibleStoryId }
      .map { Array(stories[$0...]) }
      .or(stories)
    
    func storyEffectId(storyIndex: Int) -> String {
      (storiesStartingFromLeadingVisible[safe: storyIndex]?.storyId).or("none_\(storyIndex)")
    }
                                    
    return ZStack {
      ForEach(Array(miniStories.enumerated()), id: \.element.storyId) { storyIndex, story in
        ZStack {
          StoryView(model: StoryView.Model(storyId: story.storyId, imageURL: story.imageURL))
            .storyBorderStyle(.notSeenStory)
            .storyBorderWidth(3)
            .storyBorderPadding(1)
            .matchedGeometryEffect(id: storyEffectId(storyIndex: storyIndex), in: namespace, isSource: true)
            .frame(width: Layout.MiniStoryView.size, height: Layout.MiniStoryView.size)
            .position(
              x: Layout.MiniStoryView.positionX(storyIndex: storyIndex),
              y: Layout.MiniStoryView.positionY(storyIndex: storyIndex, visibilityProgress: visibilityProgress)
            )
        }
      }
    }
    .frame(
      width: Layout.MiniStoryView.width(storiesCount: miniStories.count),
      height: Layout.MiniStoryView.size,
      alignment: .leading
    )
  }
  
  var chatsHeader: some View {
    ZStack {
      HStack(spacing: 4) {
        let miniStories = model.miniStories
        
        if !miniStories.isEmpty, case let .miniStories(transitionToProgress) = viewState {
          chatsHeaderStories(
            miniStories: miniStories,
            stories: model.stories,
            leadingVisibleStoryId: model.leadingVisibleStoryId,
            visibilityProgress: transitionToProgress
          )
        }
        
        Text("Chats")
          .multilineTextAlignment(.center)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(.appBlack)
      }
    }
    .zIndex(1)
    .padding(.bottom, 10)
    .frame(maxWidth: .infinity)
    .background {
      let color: Color = switch viewState {
      case .miniStories(transitionToProgress: 1): .appGray
      case .stories, .miniStories(_): .clear
      }
      color.ignoresSafeArea()
    }
  }
  
  func storiesList(stories: [Story], modifyStoryView: @escaping (Story, StoryView) -> some View) -> some View {
    ForEach(stories, id: \.storyId) { story in
      VStack(spacing: Layout.Stories.storyAuthorNameSpacing) {
        modifyStoryView(
          story,
          StoryView(model: StoryView.Model(storyId: story.storyId, imageURL: story.imageURL))
            .storyBorderWidth(4)
            .storyBorderPadding(2)
        )
        Text(story.authorName)
          .font(.system(size: 12, weight: .light))
          .foregroundStyle(.appBlack)
      }
    }
  }
  
  var conversationsHeaderStories: some View {
    GeometryReader { geometry in
      let stories = model.stories
      
      if stories.isEmpty {
        Text("No stories 😰")
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      } else {
        let deltaY = (listScrollOffset?.deltaY).or(0)
        
        ZStack {
          ScrollView(.horizontal) {
            LazyHStack(spacing: Layout.Stories.interStorySpacing) {
              storiesList(stories: model.stories) { story, storyView in
                storyView.anchorPreference(key: StoriesFrames.self, value: .bounds) { [story.storyId: $0] }
              }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 10)
            .frame(minWidth: geometry.size.width, alignment: .center)
          }
          .scrollClipDisabled()
          .scrollTargetBehavior(.viewAligned)
          .scrollPosition(id: Binding(get: { nil }, set: { model.leadingVisibleStoryId = $0 }), anchor: .leading)
          .opacity(
            model.debugConfig.demistifyTransitions
              ? 0.3
              : deltaY == 0 ? 1 : 0
          )
          .animation(nil, value: deltaY)
          .backgroundPreferenceValue(StoriesFrames.self) { frames in
            if case .stories = viewState, deltaY != 0 {
              transitioningStories(geometry: geometry, deltaY: deltaY, frames: frames)
            }
          }
        }
      }
    }
    .padding(.vertical, 5)
    .frame(height: Layout.Stories.height)
  }
  
  func transitioningStories(geometry: GeometryProxy, deltaY: CGFloat, frames: StoriesFrames.Value) -> some View {
    let height = geometry.size.height - deltaY
    let rect = CGRect(origin: .zero, size: geometry.size)
    let storyIdToFrame = frames
      .mapValues { geometry[$0] }
      .filter { rect.intersects($0.value) }
      .sorted { $0.value.minX < $1.value.minX }
    let storyIdToStory = model.stories.reduce(into: [String: Story]()) { $0[$1.storyId] = $1 }
    let stories = storyIdToFrame.compactMap { storyIdToStory[$0.key] }
    let estimatedWidth = storyIdToFrame
      .reduce(into: Layout.Stories.interStorySpacing * CGFloat(max(0, storyIdToFrame.count - 1))) { $0 += $1.value.width }
    let positionXOffset = (storyIdToFrame.first?.value.minX).or(0)
    let positionX = estimatedWidth / 2 + positionXOffset
    let positionY = geometry.size.height / 2 + deltaY / 2
    
    return HStack(spacing: Layout.Stories.interStorySpacing) {
      storiesList(stories: Array(stories)) { story, storyView in
        storyView.matchedGeometryEffect(id: story.storyId, in: namespace, isSource: true)
      }
    }
    .frame(height: height)
    .fixedSize(horizontal: true, vertical: false)
    .position(x: positionX, y: positionY)
  }
  
  @ViewBuilder
  var conversations: some View {
    let conversations = model.conversations
    
    if conversations.isEmpty {
      VStack {
        Spacer()
        Text("No Conversations 😨")
        Spacer()
      }
      .frame(maxWidth: .infinity)
    } else {
      LazyVStack(spacing: 0) {
        ForEach(conversations) { conversation in
          ConversationListItemView(model: conversation)
            .frame(height: 80)
            .listRowInsets(EdgeInsets())
        }
      }
      .background { scrollReader }
      .scrollTargetLayout()
    }
  }
  
  var scrollReader: some View {
    GeometryReader { geometry in
      let frame = geometry.frame(in: .global)
      
      Color.clear
        .onAppear {
          guard listScrollOffset == nil else { return }
          listScrollOffset = ListScrollOffset(initial: frame.origin, current: frame.origin)
        }
        .onChange(of: frame) { _, new in
          listScrollOffset?.current = new.origin
        }
    }
    .onChange(of: listScrollOffset) { oldScrollOffset, newScrollOffset in
      let oldDeltaY = oldScrollOffset.map(\.deltaY).or(0).rounded()
      let deltaY = listScrollOffset.map(\.deltaY).or(0).rounded()
      
      guard oldDeltaY != deltaY else { return }
      
      print("deltaY: \(deltaY)")
      
      let storiesHiddingProgress = max(0, min(deltaY / Layout.Stories.height, 1))
      let miniStoriesVisibilityThreshold = 0.3
      
      if storiesHiddingProgress >= miniStoriesVisibilityThreshold {
        let rawMiniStoriesVisibilityProgress = (storiesHiddingProgress - miniStoriesVisibilityThreshold) / (1 - miniStoriesVisibilityThreshold)
        let transitionToProgress = max(0, min(rawMiniStoriesVisibilityProgress, 1))
        
        if case .miniStories = viewState  {
          viewState = .miniStories(transitionToProgress: transitionToProgress)
        } else {
          withAnimation { viewState = .miniStories(transitionToProgress: transitionToProgress) }
        }
      } else {
        if case .miniStories = viewState  {
          withAnimation { viewState = .stories }
        } else {
          viewState = .stories
        }
      }
    }
  }
  
  var debugButton: some View {
    ZStack {
      Button {
        isDebugSheetPresented.toggle()
      } label: {
        Image(systemName: "gear")
          .resizable()
      }
      .frame(width: 40, height: 40)
      .padding(10)
      .foregroundStyle(.appWhite)
      .background(.appBlack)
      .clipShape(.circle)
      .padding([.trailing, .bottom], 20)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
  }
  
  var debugView: some View {
    List {
      Text("Debug configs")
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity, alignment: .center)
        .font(.title)
      
      Section {
        Stepper(
          label: { Text("Stories count **\(model.stories.count)**") },
          onIncrement: { model.debugConfig.storiesCount += 1 },
          onDecrement: { model.debugConfig.storiesCount = max(model.debugConfig.storiesCount - 1, 0) }
        )
        
        Stepper(
          label: { Text("Visible mini stories count **\(model.miniStories.count)**") },
          onIncrement: { model.debugConfig.visibleMiniStoriesCount += 1 },
          onDecrement: { model.debugConfig.visibleMiniStoriesCount = max(model.debugConfig.visibleMiniStoriesCount - 1, 0) }
        )
        
        Stepper(
          label: { Text("Conversations count **\(model.conversations.count)**") },
          onIncrement: { model.debugConfig.conversationsCount += 1 },
          onDecrement: { model.debugConfig.conversationsCount = max(model.debugConfig.conversationsCount - 1, 0) }
        )
      }
      
      Toggle(
        "Demystify transitions",
        isOn: Binding(
          get: { model.debugConfig.demistifyTransitions },
          set: { model.debugConfig.demistifyTransitions = $0 }
        )
      )
      
      Section {
        Toggle(
          "Use `List` as scrolling container, otherwise fallback to `ScrollView`",
          isOn: Binding(
            get: { model.debugConfig.useListAsScrollingContainer },
            set: { model.debugConfig.useListAsScrollingContainer = $0 }
          )
        )
        
        Text("I did not manage to make `scrollTargetLayout` and `scrollTargetBehavior` to work with `List`. As a result, scrolling position is not automatically set to one of stories boundaries. But the desired behaviour is achievable with `ScrollView`")
      }
    }
    .presentationDetents([.medium])
    .presentationDragIndicator(.visible)
    .presentationCornerRadius(20)
  }
}

// MARK: - Constants

private extension ConversationsView {
  enum Layout {
    enum Stories {
      static let height: CGFloat = 110
      static let verticalPadding: CGFloat = 5
      static let interStorySpacing: CGFloat = 10
      static let storyAuthorNameSpacing: CGFloat = 10
    }
    
    enum MiniStoryView {
      static let size: CGFloat = 16
      static let horizontalOffsetStep: CGFloat = 12
      static let verticalOffsetStep: CGFloat = 8
      
      
      static func positionX(storyIndex: Int) -> CGFloat {
        size / 2 + CGFloat(storyIndex) * horizontalOffsetStep
      }
      
      static func positionY(storyIndex: Int, visibilityProgress: CGFloat) -> CGFloat {
        size / 2 + CGFloat(storyIndex) * verticalOffsetStep * (1 - visibilityProgress)
      }
      
      static func width(storiesCount: Int) -> CGFloat {
        size + horizontalOffsetStep * (max(0, CGFloat(storiesCount) - 1))
      }
    }
  }
}

// MARK: - Preferences

private struct StoriesFrames: PreferenceKey {
  static let defaultValue: [String: Anchor<CGRect>] = [:]
  
  static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
    value.merge(nextValue(), uniquingKeysWith: { $1 })
  }
}

// MARK: - Preview

#Preview {
  ConversationsView(model: ConversationsViewModel())
}
