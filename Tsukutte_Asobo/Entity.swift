//
//  Entity.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2022/12/22.
//

import Foundation

//Codable　でコード、エンコード機能を持った略称。JSONのデータを型キャストできる
struct CovidInfo: Codable {
    
    //WebAPIから入手するJSONデータを格納する構造体を作成
    struct Total: Codable {
        var pcr: Int //PCR数
        var positive: Int //陽性者数
        var hospitalize: Int //入院者数
        var severe: Int // 重症者数
        var death: Int //死者数
        var discharge: Int //退院者数
    }
    
    struct Prefecture: Codable {
        var id: Int
        var name_ja: String
        var cases: Int
        var deaths: Int
        var pcr: Int
    }

    
    
    
    
}


