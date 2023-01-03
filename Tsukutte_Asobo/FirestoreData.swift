//
//  FirestoreData.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2023/01/03.
//

import Foundation
import MessageKit

struct FirestoreData { //Firestoreとのトランザクションを格納する構造体を宣言
    var date: Date? // 初期値を持っていないので、Nilを許容するようにオプショナル型にする
    var senderId: String?
    var text: String?
    var userName: String?
}

struct Sender: SenderType { //SenderTypeはMessageKitが提供するプロトコル senderIdとdisplayName変数の宣言が必要
    var senderId: String
    var displayName: String
}

struct Message: MessageType { //MessageTypeはMessageKitが提供するプロトコル
    var sender: SenderType //Sender構造体を代入して利用するプロパティ
    var messageId: String //メッセージが持つ固有ID これを参照して削除などする
    var sentDate: Date //メッセージの日付情報
    var kind: MessageKind //送信するものの種類を表すenumでできている。今回は割愛
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) { //ユーザーから投げられる写真、位置、テキストなどを受け取り、Message構造体に渡している。
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    init(text: String, sender: Sender, messageId: String, date: Date) { //init関数から間接的にアクセスして、Message構造体に値を入れていく MessageKindがString型だった場合のパターン処理
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) { //MessageKindがNSAttributedString方のテキストだった場合（装飾付き文字）のパターン処理
        
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
}

























