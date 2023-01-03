//
//  CircleChartViewController.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2023/01/01.
//

import UIKit
import Charts

class CircleChartViewController: UIViewController {
    
    let colors = Colors()
    //↓ buttomLabelに代入するため、グローバル変数としてラベルのインスタンスを宣言
    var prefecture = UILabel()
    var pcr = UILabel()
    var pcrCount = UILabel()
    var cases = UILabel()
    var casesCount = UILabel()
    var deaths = UILabel()
    var deathsCount = UILabel()
    var segment = UISegmentedControl()
    var array:[CovidInfo.Prefecture] = [] //データ操作用のアレイを初期化
    var circleView:PieChartView! // チャート　インスタンス化
    var pattern = "cases" // セグメントの選択肢を保存するグローバル変数
    var searchBar = UISearchBar() // 検索バーを参照できるよう　グローバル変数として宣言
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60)
        gradientLayer.colors = [colors.bluePurple.cgColor,
                                colors.blue.cgColor,] //配列で色を複数渡すことで、均等にグラデーションをかける
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0) //グラデーションをかける原点
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)  //グラデーションをかける先　距離でなく0-1でベクトルを右下に向かって設定している
        view.layer.insertSublayer(gradientLayer, at: 0) //layerはaddSubViewで上に載せることができない。view.layerに対し、insertSublayer(子、at:レイヤー階層)として設定する。

       
        
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 100, height: 30)
        backButton.setTitle("棒グラフ", for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside) //ボタンの挙動はSelector @objcから始まる関数の場合は＃をつける
        view.addSubview(backButton)
        
        segment = UISegmentedControl(items: ["感染者数","PCR数","死者数"])
        segment.frame = CGRect(x: 10, y: 70, width: view.frame.size.width - 20, height: 20)
        segment.selectedSegmentTintColor = colors.blue
        segment.selectedSegmentIndex = 0 //デフォルトのセグメントを指定　1つ目は0(インデックスなので)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected) //選択時の文字の色設定
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: colors.bluePurple], for: .normal) //非選択時の文字の色設定
        segment.addTarget(self, action: #selector(switchAction), for: .valueChanged) // セグメントを操作した際に発火する関数を設定
        view.addSubview(segment)
        
        searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 10, y: 100, width: view.frame.size.width - 20, height: 20)
        searchBar.delegate = self
        searchBar.placeholder = "都道府県を漢字で入力"
        searchBar.showsCancelButton = true
        searchBar.tintColor = colors.blue
        view.addSubview(searchBar)
        
        let uiView = UIView()
        uiView.frame = CGRect(x: 10, y: 480, width: view.frame.size.width - 20, height: 167)
        uiView.layer.cornerRadius = 10
        uiView.backgroundColor = .white
        uiView.layer.shadowColor = colors.black.cgColor
        uiView.layer.shadowOffset = CGSize(width: 0, height: 2)
        uiView.layer.shadowOpacity = 0.4
        uiView.layer.shadowRadius = 10
        view.addSubview(uiView)
        
        bottomLabel(uiView, prefecture, 1, y: 10, text: "東京", size: 30, weight: .ultraLight, color: colors.black)
        bottomLabel(uiView, pcr, 0.39, y: 50, text: "PCR数", size: 15, weight: .bold, color: colors.bluePurple) // x座標　センターから0.39掛けした距離に配置　乗算にすることで機種による画面サイズの違いを吸収することができる
        bottomLabel(uiView, pcrCount, 0.39, y: 85, text: "2222222", size: 30, weight: .bold, color: colors.blue)
        bottomLabel(uiView, cases, 1, y: 50, text: "感染者数", size: 15, weight: .bold, color: colors.bluePurple)
        bottomLabel(uiView, casesCount, 1, y: 85, text: "22222", size: 30, weight: .bold, color: colors.blue)
        bottomLabel(uiView, deaths, 1.61, y: 50, text: "死者数", size: 15, weight: .bold, color: colors.bluePurple)// x座標　センターから1.61掛けした距離に配置　乗算にすることで機種による画面サイズの違いを吸収することができる
        bottomLabel(uiView, deathsCount, 1.61, y: 85, text: "2222", size: 30, weight: .bold, color: colors.blue)
        
        
        view.backgroundColor = .systemGroupedBackground
        
        

        
        array = CovidSingleton.shared.prefecture
        array.sort(by: { //配列をソート クロージャでロジック組んでる
            a, b -> Bool in //a.bは配列型になっていて、arrayからデータが代入される。aとbで比較して並べ替えてる
            if pattern == "pcr" { //segmentで pcrが選ばれた場合、pcr件数順でソート
                return a.pcr > b.pcr
            } else if pattern == "deaths"{ //segmentで deathsが選ばれた場合、死者数順でソート
                return a.deaths > b.deaths
            } else { //segmentで casesが選ばれた場合、陽性件数順でソート
                return a.cases > b.cases
            }
        })
        dataSet()
        
    }
    
    // 円グラフ生成関数
    func dataSet() {
        var entrys:[PieChartDataEntry] = [] //円グラフに渡すデータを投入する配列を宣言
        if pattern == "cases" {
            for i in 0...4 { // 今回は5件分表示するので、五回繰り返し
                segment.selectedSegmentIndex = 0 //ここでセグメントのインデックスを毎回代入しないと、選択状態が切り変わらない
                entrys += [PieChartDataEntry(value: Double(array[i].cases), label: array[i].name_ja)] //Prefectures配列から陽性件数、件名を取得
            }
        } else if pattern == "pcr" {
            for i in 0...4 {
                segment.selectedSegmentIndex = 1
                entrys += [PieChartDataEntry(value: Double(array[i].pcr), label: array[i].name_ja)]
            }
        } else if pattern == "deaths" {
            for i in 0...4 {
                segment.selectedSegmentIndex = 2
                entrys += [PieChartDataEntry(value: Double(array[i].deaths), label: array[i].name_ja)]
            }
        }
        
        let circleView = PieChartView(frame: CGRect(x: 0, y: 150, width: view.frame.size.width, height: 300)) //円グラフのビューを変数に代入
        circleView.delegate = self
        circleView.centerText = "Top5"
        circleView.animate(xAxisDuration: 2, easingOption: .easeOutExpo) //x軸(データ)の表示にアニメーションをつけてる
        let dataSet = PieChartDataSet(entries: entrys) // さっき取得したデータと件名の配列を変数に代入
        dataSet.colors = [
            colors.blue, colors.blueGreen, colors.yellowGreen, colors.yellowOrange, colors.redOrange //配列内のデータへ、手前から順に5色の色をつけている
        ]
        dataSet.valueTextColor = colors.white //数字(データ)の色
        dataSet.entryLabelColor = colors.white //都道府県名(ラベル)の色
        circleView.data = PieChartData(dataSet: dataSet) //データをcircleViewにわたす
        circleView.legend.enabled = false // グラフのタイトルを表示しない
        view.addSubview(circleView) //親ビューに載せる
    }
    
    
    
    
    @objc func switchAction(sender: UISegmentedControl) { //segmentボタンを押した時、patternに名前を代入　その名前がキーとなってソートが行われる
        switch sender.selectedSegmentIndex {
        case 0:
            pattern = "cases"
        case 1:
            pattern = "pcr"
        case 2:
            pattern =  "deaths"
        default: // 例外処理
            break
        }
        loadView() // キーを変えた後、画面を読み込み直す
        viewDidLoad() // viewDidLoad関数の中のarray.sort が参照するキーが変わり、表示されるグラフの順番も変わる
    }
    
    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }


    func bottomLabel(_ parentView: UIView, _ label: UILabel, _ x: CGFloat, y: CGFloat, text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) { // UIView上のラベル　共通関数
        //各ラベルはグローバル変数として初期化済のため, label: UILableと記載し、引数を用いてどのラベルのパラメーターを編集するか指定している。 (関数内で初期化するとAPIの値を代入できない)
        
        label.text = text
        label.textColor = color
        label.textAlignment = .center // 文字の中央寄せ
        label.adjustsFontSizeToFitWidth = true //文字が多すぎてサイズオーバーした際、自動でサイズを調整する機能
        label.font = .systemFont(ofSize: size, weight: weight)
        label.frame = CGRect(x: 0, y: y, width: parentView.frame.size.width /  3.5, height: 50) //余白を持たせるため、親ビューの縦幅 / 3.5
        label.center.x = view.center.x * x - 10 // パーツ真ん中のX座標。x掛け算することで、X軸の位置を調整　親ビューが左から10ずれているので、調整として引いている
        parentView.addSubview(label)
        
        
        for i in 0..<CovidSingleton.shared.prefecture.count { //prefecture APIの配列データ（県別情報）を、index 0-prefectureの数(47)まで順番に呼び出して処理している
            if CovidSingleton.shared.prefecture[i].name_ja == "東京" {
                prefecture.text = CovidSingleton.shared.prefecture[i].name_ja
                pcrCount.text = "\(CovidSingleton.shared.prefecture[i].pcr)" //元データがIntegerのため文字リテラルでキャスト
                casesCount.text = "\(CovidSingleton.shared.prefecture[i].cases)"
                deathsCount.text = "\(CovidSingleton.shared.prefecture[i].deaths)"
            }
        }
    }
    
}


//MARK: UISearchDelegate
extension CircleChartViewController: UISearchBarDelegate { //UISearchBarのボタン操作はDelegateに沿って行われるので、呼び出す関数をdelgateに準拠させたextensionクラスに書く
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //検索ボタン押したら
        view.endEditing(true) //編集画面を終了する
        if let index  = array.firstIndex(where: { $0.name_ja == searchBar.text}) { //firstIndexメソッドを使って、検索した都道府県がarrayに存在した時のindexを取得　なかった場合に備えてバインディング
                                                                                   //whereで実際のフィルタリング $oは暗黙的に操作するデータの要素を示す この場合は検索したテキストがname_ja(県名)プロパティに合致した場合、という意味
            prefecture.text = "\(array[index].name_ja)" //各ラベル テキストを検索結果と合致する県のデータに上書き
            pcrCount.text =  "\(array[index].pcr)"
            casesCount.text = "\(array[index].cases)"
            deathsCount.text = "\(array[index].deaths)"
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.text = ""
    }
}

extension CircleChartViewController: ChartViewDelegate { //選択した棒グラフのデータをuiView上 各ラベルに反映
  
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) { //チャートが選択(highlight)されたときに起動する関数
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] { //選択(highlight)されたグラフが持つ配列データをdataSetとして代入 選択されていない場合にそなえオプショナルバインディング
            let index = dataSet.entryIndex(entry: entry) //取得したデータ配列から、prefectures配列のIndex番号を抽出
            prefecture.text = "\(array[index].name_ja)" //各ラベル テキストをハイライトされた県のデータに上書き
            pcrCount.text =  "\(array[index].pcr)"
            casesCount.text = "\(array[index].cases)"
            deathsCount.text = "\(array[index].deaths)"
        }
    }
}


