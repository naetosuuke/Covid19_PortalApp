//
//  HealthCheckViewController.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2022/12/25.
//

import UIKit
import FSCalendar //CocoaPodsライブラリから、FSCalendarを呼び出し
import CalculateCalendarLogic // 祝日を判定するライブラリ

class HealthCheckViewController: UIViewController {

    let colors = Colors()
    var point = 0 // 診断に使うポイント、診断項目のスイッチ数ぶん増減
    var today = "" // 今日の日付を入れる変数　初期化
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemGroupedBackground
        today = dateFormatter(day: Date()) // 今日の日付を代入
        
        let scrollView = UIScrollView()//スクロールする画面をインスタンス化ける
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)//画面上のどの範囲をスクロール対象にするか
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 950)//スクロールする量
        view.addSubview(scrollView) //viewはUIViewControllerに最初から付与されているメソッド　初期画面にスクロールビューをかぶせるという実装
        
        let calendar = FSCalendar() //ライブラリからカレンダーをインスタンス化
        calendar.frame = CGRect(x: 20, y: 10, width: view.frame.size.width - 40, height: 300)
        calendar.appearance.headerTitleColor = colors.bluePurple
        calendar.appearance.weekdayTextColor = colors.bluePurple
        calendar.delegate = self
        calendar.dataSource = self
        scrollView.addSubview(calendar) //さっき設定したscrollViewの上にカレンダーを載せてる
        
        let checkLabel = UILabel() // "健康チェック" と書かれたラベルを作成
        checkLabel.text = "健康チェック"
        checkLabel.textColor = colors.white
        checkLabel.frame = CGRect(x: 0, y: 340, width: view.frame.size.width, height: 21) //カレンダー上部に10の余白、カレンダー本体が300、カレンダー下に30の余白が欲しいので座標を340と設定
        checkLabel.backgroundColor = colors.blue
        checkLabel.textAlignment = .center
        checkLabel.center.x = view.center.x
        scrollView.addSubview(checkLabel)
        
        let uiView1 = createView(y: 380)//チェック項目1-5 を作成
        scrollView.addSubview(uiView1)
        createImage(parentView: uiView1, imageName: "check1")
        createLabel(parentView: uiView1, text: "37.5度以上の熱がある")
        createUISwitch(parentView: uiView1, action: #selector(switchAction))
        
        let uiView2 = createView(y: 465)
        scrollView.addSubview(uiView2)
        createImage(parentView: uiView2, imageName: "check2")
        createLabel(parentView: uiView2, text: "のどの痛みがある")
        createUISwitch(parentView: uiView2, action: #selector(switchAction))
        
        
        let uiView3 = createView(y: 550)
        scrollView.addSubview(uiView3)
        createImage(parentView: uiView3, imageName: "check3")
        createLabel(parentView: uiView3, text: "匂いを感じない")
        createUISwitch(parentView: uiView3, action: #selector(switchAction))
        
        
        let uiView4 = createView(y: 635)
        scrollView.addSubview(uiView4)
        createImage(parentView: uiView4, imageName: "check4")
        createLabel(parentView: uiView4, text: "味が薄く感じる")
        createUISwitch(parentView: uiView4, action: #selector(switchAction))
        
        
        let uiView5 = createView(y: 720)
        scrollView.addSubview(uiView5)
        createImage(parentView: uiView5, imageName: "check5")
        createLabel(parentView: uiView5, text: "だるさがある")
        createUISwitch(parentView: uiView5, action: #selector(switchAction))
        
        let resultButton = UIButton(type: .system)
        resultButton.frame = CGRect(x: 0, y: 820, width: 200, height: 40)
        resultButton.center.x = scrollView.center.x
        resultButton.titleLabel?.font = .systemFont(ofSize: 20)
        resultButton.layer.cornerRadius = 5
        resultButton.setTitle("診断完了", for: .normal) // forはイベント管理　押したら表示とかできるのかな
        resultButton.setTitleColor(colors.white, for: .normal)
        resultButton.backgroundColor = colors.blue
        resultButton.addTarget(self, action: #selector(resultButtonAction), for: [.touchUpInside, .touchUpOutside])
        scrollView.addSubview(resultButton)
        
        if UserDefaults.standard.string(forKey: today) != nil { //日付をキーにして検索　検索結果がnilじゃない == 今日の日付のデータがあった場合
            resultButton.isEnabled = false
            resultButton.setTitle("診断済み", for: .normal)
            resultButton.backgroundColor =  .white
            resultButton.setTitleColor(.gray, for: .normal)
        }
    }
    
    func createView(y: CGFloat) -> UIView { //健康診断ラベルの作成、Y座標以外は変数化する必要なし
        let uiView = UIView()
        uiView.frame = CGRect(x: 20, y: y, width: view.frame.size.width - 40, height: 70)
        uiView.backgroundColor = .white
        uiView.layer.cornerRadius = 20
        uiView.layer.shadowColor = UIColor.black.cgColor //UIColor型は使えないので、CGColorにキャストしてる
        uiView.layer.shadowOpacity = 0.3 //影の濃さ
        uiView.layer.shadowRadius = 4
        uiView.layer.shadowOffset = CGSize(width: 0, height: 2)
        return uiView
    }
    
    func createLabel(parentView: UIView, text: String){ // "健康チェック" と書かれたラベルを作成
        let label = UILabel()
        label.text = text
        label.frame = CGRect(x: 60, y: 15, width: 200, height: 40)
        parentView.addSubview(label)
    }
        
    func createImage(parentView: UIView, imageName: String){ //健診項目に載せるアイコンのパラメーターを設定
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.frame = CGRect(x:10, y: 15, width: 40, height: 40) //xy座標は、親のViewの中での位置　この場合CreateView内の座標
        parentView.addSubview(imageView)
    }
    
    @objc func switchAction(sender: UISwitch) { //Switchが実行する関数の中身　selector型で呼び出す関数なので、"@objc"をつける。 senderはcreateUISwitchから入手
        if sender.isOn { //UISwitch型のsenderのisOnのプロパティがonの場合
            point += 1 // 診断結果　はいの場合 ＋1
        } else { //isOn == onでないsenderが来た場合 (on -> offへ変えられた時)
            point -= 1 // 診断結果　いいえの場合 -1
        }
        print("point:\(point)") // pointの合計値をデバッグに表示
    }
    
    func createUISwitch(parentView: UIView, action: Selector) { //スイッチのパラメータを設定　selector型　関数名を受け取れる型。
        let uiSwitch = UISwitch()
        uiSwitch.frame = CGRect(x: parentView.frame.size.width - 60, y: 20, width: 50, height: 30)
        uiSwitch.addTarget(self, action: action, for: .valueChanged) //UISwitchがもってるvalueChangedメソッドが動いたら(forで条件定義)、親クラス内(self)のaction(関数)を実行する
        parentView.addSubview(uiSwitch)
    }
    
    @objc func resultButtonAction() { //リザルトボタンが実行する関数の中身　selector型で呼び出す関数なので、"@objc"をつける。 senderはresultButtonから入手
        let alert = UIAlertController(title: "診断を完了しますか？", message: "診断は1日に一回までです", preferredStyle: .actionSheet)
        let yesAction =  UIAlertAction(title: "完了", style: .default, handler: { action in
            var resultTitle = "" // 初期化
            var resultMessage = ""
            if self.point >= 4 { // クロージャーの中で、クロージャー外にあるものを参照する際はselfが必要となる。参照元が親クラスという意味
                resultTitle = "高"
                resultMessage = "感染している可能性が\n比較的高いです。\nPCR検査をしましょう。"
            } else if self.point >= 2 {
                resultTitle = "中"
                resultMessage = "やや感染している可能性があります。\n外出は控えましょう。"
            } else {
                resultTitle = "低"
                resultMessage = "感染している可能性は\n今のところ低いです。\n今後も気をつけましょう。"
            }
            let alert = UIAlertController(title: "感染している可能性「\(resultTitle)」", message: resultMessage, preferredStyle: .alert)
            self.present(alert, animated: true, completion: { // presentでアラートを呼び出している。アラート表示後の処理をcompletion内のクロージャに記述
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { //DIspatchQueueは自動で割り当てられるスレッド操作を手動で操作する。メインスレッドの切り替え（非同期処理）や遅延処理に用いられる。ここでは表示2秒後にクロージャを実行すると書いている
                    self.dismiss(animated: true, completion: nil) // presentメソッドで表示したアラートを消している。
                }
            })
            //診断結果をローカルに保存
            UserDefaults.standard.set(resultTitle, forKey: self.today) //　第一引数に診断結果、第二引数に今日の日付　forKeyがUserDefaultからデータを引っ張る際のキーになる
        })
        let noAction = UIAlertAction(title: "キャンセル", style: .destructive, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
}


extension HealthCheckViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? { // 診断結果をカレンダーに表示 delegate準拠のメソッド
        if let result = UserDefaults.standard.string(forKey: dateFormatter(day: date)) {
            return result
        }
        return "" // if letの例外処理　UserDefaults内にデータがなければ空の文字データを返す
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? { //診断結果の色を薄くしている dataSource準拠のメソッドを利用
        return.init(red:0, green: 0, blue: 0, alpha:  0.7) // subtitle(診断結果)の色を薄くしてる
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date ) -> UIColor? { //日付のマスの色　透明
        return .clear
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date ) -> UIColor? { //日付の枠線の色
        if dateFormatter(day: date) == today { //今日の日付と同じ場合のみ　枠線に色を入れる
            return colors.bluePurple
        }
        return .clear
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date ) -> CGFloat {//日付の枠線のまるみ
        return 0.5
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date ) -> UIColor? { //日付の数字の色
        if judgeWeekday(date) == 1 { // 日曜日の場合
            return UIColor(red: 180/255, green: 30/255, blue: 0/255, alpha: 0.9 )
        } else if judgeWeekday(date) == 7 { // 土曜日の場合
            return UIColor(red: 0/255, green: 30/255, blue: 180/255, alpha: 0.9 )
        }
        if judgeHoliday(date) { // 祝日の場合
            return UIColor (red: 180/255, green: 30/255, blue: 0/255, alpha: 0.9 )
        }
        return colors.black // 平日の場合
    }
    //Date型の日付の出力書式をyyyy-MM-dd time 時差 ⇨ yyyy-MM-ddへ変更している 枠線の色は今日と同じ日付という条件なので、デフォルトの通り時間、秒まで入っていると比較できない
    func dateFormatter(day: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: day) //from Date型のデータに返している
    }
    
    //曜日判定（月曜1、日曜7）
    func judgeWeekday(_ date: Date) ->Int { //Xcodeに元から用意されているCalendarインスタンスの機能を使う
        let calendar = Calendar(identifier: .gregorian) //Identifierで西暦を指定
        return calendar.component(.weekday, from: date) //componentsメソッド 第一引数に.year, .month, .weekday等を渡すと 第二引数のfromにDate型の値を投入することで、日付情報から第一引数で指定した情報を返す。
        // .weekdayの場合、日曜が1〜土曜が7として数値を返す
    }
    
    //祝日判定
    func judgeHoliday(_ date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian) // 引数の日付 年月日で分けて宣言
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic() // 祝日判定に使うクラスのインスタンス化
        let judgeHoliday = holiday.judgeJapaneseHoliday(year: year, month: month, day: day) //　年月日をそれぞれ引数として渡すと、祝日か否かのBoolを返すメソッド
        return judgeHoliday
    }
    
    
    
}


/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/
