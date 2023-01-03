//
//  ChartViewController.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2022/12/30.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    
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
    var chartView:HorizontalBarChartView! //チャート　インスタンス化
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
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside) //ボタンの挙動はSelector @objcから始まる関数の場合は＃をつける
        view.addSubview(backButton)
        
        
        let nextButton = UIButton(type: .system)
        nextButton.frame = CGRect(x: view.frame.size.width - 105, y: 25, width: 100, height: 30)
        nextButton.setTitle("円グラフ", for: .normal)
        nextButton.setTitleColor(colors.white, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(goCircle), for: .touchUpInside)
        view.addSubview(nextButton)
        
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
        
        chartView = HorizontalBarChartView(frame: CGRect(x: 0, y: 150, width: view.frame.size.width, height: 300)) //縦向きのグラフを横に変更しているので、設定がややこしい
        chartView.animate(xAxisDuration: 1.0, easingOption: .easeOutCirc) //アニメーション設定　xAxisDurationは横に伸びるアニメ　1秒かけて伸びる easingOptionはアニメの種類
        chartView.xAxis.labelCount = 10 //x軸ラベルの数
        chartView.xAxis.labelTextColor = colors.bluePurple
        chartView.doubleTapToZoomEnabled = false //ダブルタップのズームを禁止
        chartView.delegate = self
        chartView.pinchZoomEnabled = false //ピンチズーム禁止
        chartView.leftAxis.labelTextColor = colors.bluePurple
        chartView.xAxis.drawGridLinesEnabled = false //X軸のグリッド削除
        chartView.legend.enabled = false //チャート名の説明を削除　truenにするとチャート名などが表示される
        chartView.rightAxis.enabled = false // 右側の軸を表示しない(ここではした)
        
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
    
    // 横棒グラフ生成関数
    func dataSet() {
        var names:[String] = [] //縦軸　都道府県名の配列
        for i in 0...9 { //　十回繰り替えす
            names += ["\(self.array[i].name_ja)"] // arrayが持つPrefectureデータのname_ja をnames配列に追加
        }
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:names) //chartView x軸へnames配列を値としてコンバートして代入している
        
        var entries:[BarChartDataEntry] = [] //横軸 県別データの値
        for i in 0...9 { // 十回繰り替えす
            if pattern == "cases" { //segmentで選ばれた値をもとに整列して表示
                segment.selectedSegmentIndex = 0 //何でここで呼び出してるの？
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.array[i].cases))] //配列 BarChartDataEntry のキーxにインデックス番号(forで渡される試行回数) キーyにi番目のPrefecture.casesの値を代入
            } else if pattern == "pcr" {
                segment.selectedSegmentIndex = 1 //
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.array[i].pcr))]
            } else {
                segment.selectedSegmentIndex = 2 //
                entries += [BarChartDataEntry(x: Double(i), y: Double(self.array[i].deaths))]
            }
            
        }
        let set = BarChartDataSet(entries: entries, label: "県別状況") //データセット用のインスタンス生成 引数entriesに表示したいデータ、labelに表題を渡す でもcahrtView.legent,enabled = falseにしてるので表題は常時されない
        set.colors = [colors.blue] //棒グラフの色を指定 なんで配列か？棒一本一本にプロパティがあるので、まとめて代入するって...コト？
        set.valueTextColor = colors.bluePurple // 棒グラフの頭に表示される値の色
        set.highlightColor = colors.white // 棒グラフのデータをタップした時の色(今の色に指定の色がまざる感覚)
        chartView.data = BarChartData(dataSet: set) // chartView dataプロパティに上で整形したデータ情報を代入
        view.addSubview(chartView)
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
    @objc func goCircle() {
        performSegue(withIdentifier: "goCircle", sender: nil)
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
extension ChartViewController: UISearchBarDelegate { //UISearchBarのボタン操作はDelegateに沿って行われるので、呼び出す関数をdelgateに準拠させたextensionクラスに書く
    
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


//MARK: ChartViewDelegate

extension ChartViewController: ChartViewDelegate { //選択した棒グラフのデータをuiView上 各ラベルに反映
  
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


