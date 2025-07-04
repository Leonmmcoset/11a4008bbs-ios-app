//
//  Discussion.swift
//  LiangJianForum
//
//  Created by Romantic D on 2023/6/25.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let discussion = try? JSONDecoder().decode(Discussion.self, from: jsonData)

import Foundation

// MARK: - Discussion
/// 表示从 JSON 数据解析得到的讨论数据。
struct Discussion: Codable, Hashable {
    /// 包含相关链接的对象。
    let links: Links
    /// 讨论数据数组。
    let data: [Datum]
    /// 包含的额外数据数组。
    let included: [Included]
}

// MARK: - Datum
/// 表示单个讨论数据项。
struct Datum: Codable, Hashable {
    /// 数据类型。
    let type, id: String
    /// 数据的属性。
    let attributes: DatumAttributes
    /// 数据的关联关系。
    let relationships: DatumRelationships
}

// MARK: - DatumAttributes
/// 表示单个讨论数据项的属性。
struct DatumAttributes: Codable, Hashable {
    /// 讨论的标题。
    let title, slug: String
    /// 评论数量。
    let commentCount, participantCount: Int
    /// 创建时间。
    let createdAt: String
    /// 最后发布时间。
    let lastPostedAt: String?
    /// 最后发布的评论编号。
    let lastPostNumber: Int
    /// 是否置顶。
    let isSticky: Bool
    /// 是否锁定。
    let isLocked: Bool
    /// 是否包含投票。
    let hasPoll: Bool?
    /// 是否有最佳答案。
    let hasBestAnswer: HasBestAnswer?
    /// 是否在首页显示。
    let frontpage: Bool?
    /// 是否隐藏。
    let isHidden : IsHidden?
    /// 订阅状态。
    let subscription: String?
//    let canReply, canRename, canDelete, canHide: Bool
//    let isApproved: Bool
//    let bestAnswerSetAt, subscription: JSONNull?
//    let canTag, isSticky, canSticky, isStickiest: Bool
//    let isTagSticky, canStickiest, canTagSticky, canReset: Bool
    /// 查看次数。
    let viewCount: Int?
//    let canViewNumber, frontpage: Bool
//    let frontdate: String?
//    let front, canSelectBestAnswer, isLocked, canLock: Bool
//    let bookmarked: Bool
}

enum HasBestAnswer: Codable, Hashable {
    case bool(Bool)
    case integer(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        throw DecodingError.typeMismatch(HasBestAnswer.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for HasBestAnswer"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let x):
            try container.encode(x)
        case .integer(let x):
            try container.encode(x)
        }
    }
}

// MARK: - DatumRelationships
struct DatumRelationships: Codable, Hashable {
    let user : User
//    let lastPostedUser: User
//    let tags: ClarkwinkelmannWhoReaders
//    let firstPost: FirstPost
//    let stickyTags, clarkwinkelmannWhoReaders: ClarkwinkelmannWhoReaders
}

// MARK: - ClarkwinkelmannWhoReaders
//struct ClarkwinkelmannWhoReaders: Codable {
//    let

// MARK: - DAT
struct DAT: Codable, Hashable {
    let type, id: String
}

// MARK: - FirstPost
struct User: Codable, Hashable {
    let data: DAT
}

// MARK: - Included
struct Included: Codable, Hashable {
    let type, id: String
    let attributes: IncludedAttributes
//    let relationships: IncludedRelationships?
}

// MARK: - IncludedAttributes
struct IncludedAttributes: Codable, Hashable {
    let username, displayName: String?
    let avatarUrl: String?
//    let slug: String?
//    let number: Int?
//    let createdAt: String?
//    let contentType, contentHTML: String?
//    let renderFailed: Bool?
//    let lastReadAt: String?
//    let lastReadPostNumber: Int?
//    let subscription, unread: JSONNull?
//    let nameSingular, namePlural, color, icon: String?
//    let isHidden: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case username, displayName
//        case avatarURL = "avatarUrl"
//        case slug, number, createdAt, contentType
//        case contentHTML = "contentHtml"
//        case renderFailed
//        case lastReadAt = "last_read_at"
//        case lastReadPostNumber = "last_read_post_number"
//        case subscription, unread, nameSingular, namePlural, color, icon, isHidden
//    }
}

// MARK: - IncludedRelationships
//struct IncludedRelationships: Codable {
//    let groups: ClarkwinkelmannWhoReaders?
//    let user: FirstPost?
//}

// MARK: - Links
struct Links: Codable, Hashable {
    let first: String
    let prev: String?
    let next: String?
}

// MARK: - Encode/decode helpers

//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    public var hashValue: Int {
//        return 0
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
//}





