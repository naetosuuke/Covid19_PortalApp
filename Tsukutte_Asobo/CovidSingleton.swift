//
//  CovidSingleton.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2023/01/01.
//

import Foundation



//棒グラフ、円グラフは同じデータを使用するため、一回通信で得た情報を使いまわすよう実装(通信回数の圧縮)
//シングルトン と呼ばれる実装方法を使う。アプリが開いている間はデータを保存できる。アプリが消えるとデータも消える。
//起動中のみデータを使いまわしたいときに使う。(RealmSwiftという外部ライブラリでも同じことができる)

class CovidSingleton {
    
    private init() {} // 何もしていない、本来初期化処理をする部分だが、ここに何も書かないことでクラスが初期化されることを防ぐ
    static let shared = CovidSingleton() //
    var prefecture:[CovidInfo.Prefecture] = []
    
}





