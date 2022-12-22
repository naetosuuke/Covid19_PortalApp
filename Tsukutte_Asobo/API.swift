//
//  API.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2022/12/22.
//

import Foundation

struct CovidAPI {
    //static　つけると、中の関数をインスタンス化なしで使える　CovidAPI().getTotal でなく Covid.getTotalとして記載可能。
    //引数completionの型を、"@escaping(構造体)"と書くことで、この引数の値を構造体の型にいれ、さらに関数外でも呼び出しができる（ @escapeの効果 ）。
    //Void　戻り値なしの意味。今回は引数completionに戻り値をかえすため
    //ちなみに、HTTPプロトコルはデフォルトで使えなくなっているので、info.plistのマニフェストをいじって使えるようにかえる
    static func getTotal(completion: @escaping (CovidInfo.Total) -> Void) {
        let url = URL(string: "https://covid19-japan-web-api.vercel.app/api/v1/total")// APIのURLかいてる
        let request = URLRequest(url: url!)//リクエストように型変換 URLは接続可否がわからないため、オプショナルになっているため、強制アンラップしている。
        URLSession.shared.dataTask(with: request) { (data, response, error) in// URLにリクエストを投げている。帰ってきたdata, response, errorをin以降の処理に渡している
            
            if error != nil { //エラーの条件式(エラー内容が空でなければ、エラーを表示する)
                print("error:\(error!.localizedDescription)")//エラーは必ずあるわけではないので、強制アンラップ
            }
             if let data = data {//オプショナルバインディング
                 let result = try! JSONDecoder().decode(CovidInfo.Total.self, from: data)//ここでデコードしてる。 dataをCovidInfo.Total(さっきつくった構造体)型に変換, selfは？ try!はエラーの可能性のある処理を実行
                 completion(result)//APIで撮ってきたdataをデコードしresultに格納したものを、引数completionに渡している。
            }
        }.resume()
    }
}











