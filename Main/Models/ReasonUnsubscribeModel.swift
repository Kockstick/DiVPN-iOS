//
//  ReasonUnsubscribeModel.swift
//  Outline
//
//  Created by Diesperov Konstantin on 05.10.2025.
//

struct ReasonUnsubscribeModel: Codable{
    let reason: ReasonUnsubscribe
}

enum ReasonUnsubscribe: Int, Codable {
    case NotUsing
    case TooExpensive
    case UnstableConnection
    case AppIssues
    case Other
}
