//
//  ViewController.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2022/12/21.
//

import UIKit

class ViewController: UIViewController {
    
    let colors = Colors() // Colors構造体をインスタンス化
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpGradation()
        setUpContent()

        /*
         let uiView = UIView()
         uiView.frame.size = CGSize(width: 200, height: 200)//たてよこ
         uiView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)//x軸/y軸　viewの1/2地点⇨まんなか
         uiView.backgroundColor = UIColor.systemBlue
         //UIViewControllerクラスにはデフォルトでviewが画面に描写されている。
         //addSubviewメソッドは、親.adsSubview(子)と書くことで、親の上に子のViewを載せることができる。
         view.addSubview(uiView)
         
         let uiView2 = UIView()
         uiView2.frame.size = CGSize(width: 150, height: 150)//たてよこ
         uiView2.center = CGPoint(x: uiView.frame.size.width / 2, y: uiView.frame.size.width / 2)//x軸/y軸　viewの1/2地点⇨まんなか
         uiView2.backgroundColor = .cyan
         //UIViewControllerクラスにはデフォルトでviewが画面に描写されている。
         //addSubviewメソッドは、親.adsSubview(子)と書くことで、親の上に子のViewを載せることができる。
         uiView.addSubview(uiView2)
         */
        
    }
    
    func setUpContent(){ //画面の真ん中にcontentViewをおくメソッド
        let contentView = UIView()
        contentView.frame.size = CGSize(width: view.frame.size.width, height: 340) //横　view通り、縦340
        contentView.center = CGPoint(x: view.center.x, y: view.center.y) //中心の座標として、viewのcenterのxy座標を代入
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30 //角をまるめる
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2) //影の方向 width右、height下にのびる
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOpacity = 0.5 //影の透明度
        view.addSubview(contentView) // viewの上にcontentViewをのせている
        
        view.backgroundColor = .systemGray6 //レイヤーの下のViewの色をグレーにした
        
        let labelFont = UIFont.systemFont(ofSize: 15, weight: .heavy) //これからつくるラベルのパラメータを作成
        let size = CGSize(width: 150, height: 50)
        let color = colors.bluePurple
        let leftX = view.frame.size.width * 0.33 //左寄りのX座標 viewの33/100
        let rightX = view.frame.size.width * 0.80 //右寄りのX座標 viewの80/100
        setUpLabel("Covid in Japan",
                   size: CGSize(width: 180, height: 35),
                   centerX: view.center.x - 20, y: -60,
                   font: .systemFont(ofSize: 25, weight: .heavy), //.heavyプロパティ　太字
                   color: .white, contentView)
        setUpLabel("PCR数", size: size, centerX: leftX, y: 20 , font: labelFont, color: color, contentView)
        setUpLabel("感染者数", size: size, centerX: rightX, y: 20 , font: labelFont, color: color, contentView)
        setUpLabel("入院者数", size: size, centerX: leftX, y: 120 , font: labelFont, color: color, contentView)
        setUpLabel("重症者数", size: size, centerX: rightX, y: 120 , font: labelFont, color: color, contentView)
        setUpLabel("死者数", size: size, centerX: leftX, y: 220 , font: labelFont, color: color, contentView)
        setUpLabel("退院者数", size: size, centerX: rightX, y: 220 , font: labelFont, color: color, contentView)
        
        let height = view.frame.size.height / 2
        setUpButton("健康管理", size: size, y: height + 190, color: colors.blue, parentView: view) //height viewの半分の高さ＋190ピクセル
        setUpButton("県別状況", size: size, y: height + 240, color: colors.blue, parentView: view)  //height viewの半分の高さ＋240ピクセル
        //width view幅から-50ピクセル addTargetメソッド 引数selfはクラスの指定、引数actionで関数を書く。(@objc　から始まる関数は#selectorとつける) 引数forは起動のタイミング
        setUpImageButton("conversation", x: view.frame.size.width - 50).addTarget(self, action: #selector(chatAction), for: .touchDown)
        setUpImageButton("reload", x: 15).addTarget(self, action: #selector(reloadAction), for: .touchDown)
        
        //アニメーションで動くウイルス画像
        let imageView = UIImageView()
        let image = UIImage(named: "virus")
        imageView.image = image
        imageView.frame = CGRect(x: view.frame.size.width, y: -65, width: 50, height: 50) //x座標を画面外（画面幅と同じ座標）にして、アニメでこっちにつれてくる
        contentView.addSubview(imageView)
        //アニメーションのメソッド
        //withDUration:アニメ時間, delay:コードが読まれてからのタイムラグ、option:アニメーションのスタイル、animation:クロージャ内に変化させたい値をアニメーションで表現する領域
        UIView.animate(withDuration: 1.5, delay: 0.5, animations: {
            imageView.frame = CGRect(x: self.view.frame.size.width - 100, y: -65, width:50, height: 50) // 0.5秒のラグ、1.5秒のアニメーションで、この座標、サイズに移動させる。
            imageView.transform = CGAffineTransform(rotationAngle: -90) //サイズや位置を変化させたいときに使用。CGAffineTransformのrotationAngleによって、画像を90度回転させている。
        }, completion: nil)//終了時の通知はなし

        setUpAPI(parentView: contentView)

    }

    func setUpAPI(parentView: UIView) { //APIでとってきたデータをラベルに投入して表示する
        let pcr = UILabel() //各ラベルのインスタンス化
        let positive = UILabel()
        let hospitalize = UILabel()
        let severe = UILabel()
        let death = UILabel()
        let discharge = UILabel()

        let size = CGSize(width: 200, height: 40)//パラメーターの宣言
        let leftX = view.frame.size.width * 0.38
        let rightX = view.frame.size.width * 0.85
        let font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        let color = colors.blue
        
        setUpAPILabel(pcr, size: size, centerX: leftX, y: 60, font: font, color: color, parentView) //ラベルにパラメーターをいれている
        setUpAPILabel(positive, size: size, centerX: rightX, y: 60, font: font, color: color, parentView)
        setUpAPILabel(hospitalize, size: size, centerX: leftX, y: 160, font: font, color: color, parentView)
        setUpAPILabel(severe, size: size, centerX: rightX, y: 160, font: font, color: color, parentView)
        setUpAPILabel(death, size: size, centerX: leftX, y: 260, font: font, color: color, parentView)
        setUpAPILabel(discharge, size: size, centerX: rightX, y: 260, font: font, color: color, parentView)
        
        CovidAPI.getTotal(completion: {(result: CovidInfo.Total) -> Void in //構造体にいれたAPIデータを呼び出している
            DispatchQueue.main.async {//クロージャ内の処理をメインスレッドで行うようにする関数　表示にかかわる処理はメインスレッドで行わなければならない
                pcr.text = "\(result.pcr)"
                positive.text = "\(result.positive)"
                hospitalize.text = "\(result.hospitalize)"
                severe.text = "\(result.severe)"
                death.text = "\(result.death)"
                discharge.text = "\(result.discharge)"
            }
        })
    }
    
    func setUpAPILabel(_ label: UILabel, size: CGSize, centerX: CGFloat, y: CGFloat, font: UIFont, color: UIColor, _ parentView: UIView){ //ラベルの設定を入れている(構造体でよくない？)
        label.frame.size = size
        label.center.x = centerX
        label.frame.origin.y = y
        label.font = font
        label.textColor =  color
        parentView.addSubview(label)
    }
    
    func setUpImageButton(_ name: String, x: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: name), for: .normal) // for ボタンの状態 normalで通常、selectedで選択状態。UIImageは、UIImage(named:ファイル名)とすることでAssetファイルに保存した画像を呼び出す。
        button.frame.size = CGSize(width: 30, height: 30) // ボタンのサイズ
        button.tintColor =  .white // 画像の色を変えられる。
        button.frame.origin = CGPoint(x: x, y: 70) //ボタンの座標
        view.addSubview(button) // viewの上に載せる
        return button // UIButtonのインスタンスを戻り値として返している
    }
    
    @objc func reloadAction() {
        loadView()
        viewDidLoad()
    }
    
    @objc func chatAction(){
        print("タップchat")
    }
    
    func setUpButton(_ title: String, size:CGSize, y:CGFloat, color: UIColor, parentView: UIView){
        let button = UIButton(type: .system) //UIボタンのインスタンス生成　　type.systemとすることでボタンの機能をもたせる（タップすると明るくなる）
        button.setTitle(title, for: .normal) //第二引数　ボタンの状態を設定　.selectedなどがある
        button.frame.size = size
        button.center.x = view.center.x
        let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.kern :8.0]) //NSAttributeString　文字列に特殊な加工をしたい時などに使う。 今回は文字同士の間隔を設定 第二引数attvibutesを操作すれば色々使える。枠をつけたりすることもでる。
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.frame.origin.y = y
        button.setTitleColor(color, for:.normal)
        parentView.addSubview(button)
    }
    
    func setUpLabel(_ text: String, size: CGSize, centerX: CGFloat, y:CGFloat, font:UIFont, color:UIColor, _ parentView: UIView){
        let label = UILabel() //UILabelクラスでラベルを生成できる。
        label.text = text
        label.frame.size = size
        label.center.x = centerX
        label.frame.origin.y = y
        label.font = font
        label.textColor = color
        parentView.addSubview(label) //のせる下のViewを宣言
        
    }
    
    
    

    func setUpGradation() { //グラデーションのレイヤーを当てるメソッド
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x:0, y:0, width: view.frame.size.width, height: view.frame.size.height / 2)
        gradientLayer.colors = [colors.bluePurple.cgColor, colors.blue.cgColor]// CGColorの配列　UIColor型でなく、cgColor型へ変換している(グラデーションにUIColor型は使えない)
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)// グラデーションのレイヤー開始ポイント 二次元座標　0-1で調整
        gradientLayer.endPoint =  CGPoint.init(x:0.5, y: 0.5)// グラデーションのレイヤー終了ポイント
        view.layer.insertSublayer(gradientLayer, at:1) //view.layerプロパティのinsertSublayerメソッドで設定したレイヤーをviewに適用
        
        
        
    }
    
    

}

