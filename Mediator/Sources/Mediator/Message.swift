//
//  File.swift
//  

import Foundation

final class Session: Codable {
    var SessionID: String
    var Participants: [String]
    
    init(SessionID: String, Participants: [String]) {
        self.SessionID = SessionID
        self.Participants = Participants
    }
}

public struct Message: Codable {
    public let session_id: String
    public let from: String
    public let to: [String]
    public let body: String
    public let hash: String
    
    public init(session_id: String, from: String, to: [String], body: String,hash: String) {
        self.session_id = session_id
        self.from = from
        self.to = to
        self.body = body
        self.hash = hash
    }
}

final class cacheItem: Codable{
    var messages: [Message]
    
    init(messages: [Message]) {
        self.messages = messages
    }
}
