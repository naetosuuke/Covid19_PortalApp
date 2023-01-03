//
//  ChatViewController.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2023/01/02.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatViewController: MessagesViewController, MessagesDataSource, MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    let colors = Colors()
    private var userId = "" //UUIDいれる変数の初期化
    private var firestoreData:[FirestoreData] = [] //別swiftファイルで作った構造体をもつ配列の初期化
    private var messages: [Message] = [] //Message型の構造体を初期化 MessageKitはFirestorData型ではメッセージを表示できないので型キャストする
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Firestore.firestore().collection("Messages").document().setData([ //firestore Messageコレクション下にデータを送信している テストコードなのでビューが読み込まれるたび起動
            "date": Date(),
            "senderId": "testID",
            "text": "textText",
            "userName": "testName"
        ])
        Firestore.firestore().collection("Messages").getDocuments(completion: { //Firestore テスト受信 messageコレクションのドキュメントを全て取得　完了後の処理をcompletionクロージャに記載
            (document, error) in //帰ってきたデータがdocumentに、エラーがerrorに格納されている。
            if error != nil { //エラーがあるとき、下記にて出力　#lineはエラーが発生したコードを出力してくれる
                print("ChatViewController:Line(\(#line):error:\(error!)")
            } else {
                if let document = document { //オプショナルバインディング
                    for i in 0..<document.count { //ドキュメント下　データの個数文繰り返し
                        var storeData = FirestoreData() // 構造体をインスタンス化
                        //ドキュメントから取得した配列を、インデックス番号順に繰り返し処理　 get(フィールド名)でドキュメントの中の指定したデータを取得　この際、かならず明示的に型を宣言する必要がある
                        storeData.date = (document.documents[i].get("date")! as! Timestamp).dateValue() // Firestoreは、日付情報をDate型で保存してもTimestamp型で返されるので、型キャストでTimestamp型であることを明示しながら、Timestamp型をDate型に変換する dateValue()メソッドを使う
                        storeData.senderId = document.documents[i].get("senderId")! as? String //残りもString型としてキャストする　そうしないと型が持つプロパティ、メソッドが使えないため
                        storeData.text = document.documents[i].get("text")! as? String
                        storeData.userName = document.documents[i].get("userName")! as? String
                        self.firestoreData.append(storeData) // 上記3種のプロパティを持つstoreDataを、firestoreDataという構造体の配列に追加する。
                        print(self.firestoreData)
                    }
                }
                self.messages = self.getMessages() // messages変数に、getMessages関数でdirestoreData -> Messagesに変換したメッセージデータを代入
                self.messagesCollectionView.reloadData() //MessageKitが持っているビューのプリセット　メッセージ描画を担当 データを受信後リロード
                self.messagesCollectionView.scrollToLastItem() // リロード後、最新のビューを見るため最下段まで自動スクロール
            }
        })

        if let uuid = UIDevice.current.identifierForVendor?.uuidString { //UUIDを取得している オプショナル型なので、if letで取得できた場合のみuuidに代入
            userId = uuid
            print(userId) //デバッグエリアで確認
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.contentInset.top = 70 //MessageViewControllerはデフォルトで画面いっぱいに広がるため、上の部分(contentInset.top)に70の余白をつける ここにヘッダーをつける
        
        let uiView = UIView()
        uiView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        view.addSubview(uiView)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = colors.white
        label.text = "Doctor"
        label.frame = CGRect(x: 0, y: 20, width: 100, height: 40)
        label.center.x = view.center.x
        label.textAlignment = .center
        uiView.addSubview(label)
        
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        uiView.addSubview(backButton)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        gradientLayer.colors = [colors.bluePurple.cgColor,colors.blue.cgColor,]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        uiView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    func currentSender() -> MessageKit.SenderType { //送信者の判別　自分の場合に利用
        return Sender(senderId:userId, displayName: "MyName")
    }
    func otherSender() -> MessageKit.SenderType { //自分以外の場合に利用
        return Sender(senderId: "-1", displayName: "OtherName")
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType { //メッセージを表示する関数
        return messages[indexPath.section] //indexPathで1つずつアクセスしている。0から順に投げられ、配列の頭からアクセスしていく流れ
    }
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int { //メッセージの個数を返している関数
        return messages.count //配列の要素の数　countメソッドで返している
    }
    func createMessage(text:String, date: Date, _ senderId: String) -> Message { //firestoreDataのtext, date, senderIdをそれぞれ受け取り、Message型としてキャストする
        let attributedText = NSAttributedString(string: text, attributes: [.font:UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white]) // String型をNSAttributedString型にキャスト サイズと色を付与
        let sender = (senderId == userId) ? currentSender() : otherSender() //エルビス演算子 条件 ? A : Bで表し、TrueならA FalseならBを返す。メッセージデータのsenderIdと端末のuserIdが合致するか確認している。 合致すればcurrentSender(), 合致しなければotherSender()をsenderに代入
        return Message(attributedText: attributedText, sender: sender as! Sender, messageId: UUID().uuidString, date: date) //変換した引数+UUIDをMessageインスタンスに渡し、return
    }
    
    //MARK: MessageDisplayDelegate
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor { //描画の際に呼び出され、背景色をDelegateで返す (通知データ型はUIColor)
        return isFromCurrentSender(message: message) ? colors.blueGreen : colors.redOrange // isFromCurrentSender関数にMessage構造体を入れると、自分のメッセージか否かをBoolで返す。その結果をエルビス演算子で分岐させて背景色を分ける
    }
    
    //MARK: MessageLayoutDelegate
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat { //描写の際に呼び出され、メッセージセル下の高さを設定（日付を入れるすきまをあける）
        return 16
    }
    //MARK: MessageDataSourse
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? { //メッセージ下部に文字を表示する　装飾文字を返す
        let formatter = DateFormatter() //日付フォーマットを調整
        formatter.dateStyle = .short // 日付 dd/MM/yyへ変換
        formatter.timeStyle = .short // 時間 hh/mm　AM/PM へ変換
        let dateString = formatter.string(from: message.sentDate) // DateFormatterインスタンスの引数に送信日を渡し、規定のフォーマットにコンバート
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption2)]) // 装飾文字を返してる　attributes(装飾内容)は配列型 :[x:y]と記載して複数渡すことができる
    }
    //MARK: MessagesDisplayDelegate
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) { //アイコン画像を設定する
        let avatar: Avatar //MessageKitが持つAvatar型を使う
        avatar = Avatar(image: UIImage(named: isFromCurrentSender(message: message) ? "me" : "counterpart")) //Avatarに設定するUIImageを代入 エルビス演算子で送信元を自分/自分以外を判別し、Bool結果にあわせて取得したい画像ファイル名を記載する
        avatarView.set(avatar: avatar) //.setメソッドで画像をセットできる
    }
    func getMessages() -> [Message] { //createMessageメソッドで作成したMessage型データを取得
        var messageArray:[Message] = []
        for i in 0..<firestoreData.count { //direstoreDataの数だけループ
            messageArray.append(createMessage(text: firestoreData[i].text!, date: firestoreData[i].date!, firestoreData[i].senderId!)) //Messae型の配列messageArrayに、createMessageで変換したデータを追加（データ一個一個をcreateMessageでコンバートし、それを配列としてしまい直している）
        }
        messageArray.sort(by: { //messageArrayを日付順に並べる
         a, b -> Bool in //　配列から要素が2つ渡され、一方をa, もう一方をbに代入
            return a.sentDate < b.sentDate //a<bならTrue,　違えばfalseを返す。
        })
        return messageArray
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) { //送信ボタン押下時に起動する関数
        for component in inputBar.inputTextView.components { //inputBar.inputTextView.components　に入力情報が格納されている。入力情報は複数想定されているので、for in 文で1つずつ取り出す(普通のfor分)
            if let text = component as? String { //コンポーネントの中を確認 オプショナルの文字型にキャストしてる
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])//文字に装飾を与えていうる
                let message = Message(attributedText: attributedText, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: Date()) //Messageインスタンスを作成して、MessageKitでチャット表示に必要な型のデータを作成
                messages.append(message) //メッセージ配列 messagesにmessageを追加
                messagesCollectionView.insertSections([messages.count - 1]) //messagesCollectionViewはメッセージ表示を担当しているコレクションビュー(TableViewみたいなもん？) 最新のメッセージなので一番下にinsertSection([messages.count - 1])としセクション番号を設定している。自動で通し番号はつかないので、送信時にこの処理でつけてあげている
                sendToFirestore(message: text) //FireStore送信用の関数にに引数textを渡している。
            }
        }
        inputBar.inputTextView.text = "" //入力欄を空にする
        messagesCollectionView.scrollToLastItem() //一番下にスライド
    }
    
    func sendToFirestore(message: String) { // Firestoreに入力欄のデータを送信
        Firestore.firestore().collection("Messages").document().setData([ //Messagesコレクション配下に、固有IDを持たせたデータを辞書型(キーバリュー型)で保存
            "date": Date(),
            "senderId": userId,
            "text": message,
            "userName": userId
        ], merge: false) { err in //merge: falseと書くと、Firestoreのコレクションにmergeできなかった場合 errを返す。
            if let err = err {
                print("Error writing document: \(err)")
            }
            
        }
    }
    
    
}
