// Copyright © 2020 Metabolist. All rights reserved.

import Mastodon

public enum CollectionItem: Hashable {
    case status(Status, StatusConfiguration)
    case loadMore(LoadMore)
    case account(Account)
}

public extension CollectionItem {
    struct StatusConfiguration: Hashable {
        public let isContextParent: Bool
        public let isPinned: Bool
        public let isReplyInContext: Bool
        public let hasReplyFollowing: Bool

        init(isContextParent: Bool = false,
             isPinned: Bool = false,
             isReplyInContext: Bool = false,
             hasReplyFollowing: Bool = false) {
            self.isContextParent = isContextParent
            self.isPinned = isPinned
            self.isReplyInContext = isReplyInContext
            self.hasReplyFollowing = hasReplyFollowing
        }
    }
}

public extension CollectionItem.StatusConfiguration {
    static let `default` = Self()
}