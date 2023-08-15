# Tsukutte_Asobo
just for self learning, not for distribution (Soshi Tanaka All Rights Reserved)<br>
https://www.amazon.co.jp/【Swift】作って学ぼうiOSアプリ開発-田中颯志-ebook/dp/B08V8KW39K<br>

本アプリは、上記書籍の内容に基づき、各要素の求術取得を目的としてハンズオン形式で作成した。<br>

【アプリ概要】<br>
毎日のコロナウイルス感染者数をAPIで取得し、県/症状別の患者数を表示する。また、カレンダーを用いて毎日の健康状態を記録する機能と、<br>
担当医とのやりとりを想定した、Firebaseを使用したチャット機能を有する。<br>

【使用ライブラリ】<br>
FSCalendar <br>
健康状態　確認用ページにカレンダー画面を表示するため使用<br>
  
CalculateCalendarLogic<br>
カレンダーに日本の祝日を表記するため使用<br>
  
Charts<br>
感染者数のチャートグラフを作成するために使用<br>
  
Firebase<br>
チャット機能実装に際し、メッセージデータの送受信、保存のため使用<br>

MessageKit<br>
チャット画面の実装のため使用<br>

MessageInputBar<br>
チャット画面の実装のため使用<br>
  
PKHUD<br>
初回起動時、コロナウイルス感染者数APIを受信している間の画面処理のため使用(非同期処理)<br>


【各画面の説明】<br>
・ホーム画面<br>
初回起動時、コロナ感染者を数APIで取得し、以降セッションが続く間保持(シングルトン)<br>
それを元に、PCR数、感染者数、入院者数、重症者数、死者数、退院数の総計を記載<br>

・健康管理<br>
健康チェック項目を埋め、送信ボタンを押すと、カレンダー画面に当日の健康状態が記録される。<br>
健康状態はUserDefaultにより、端末上で保持される。<br>

・チャット画面<br>
担当医師とチャットで話せる、という趣旨の画面<br>
担当医師とのメッセージ送受信機能を、FireBaseを用いて実装<br>

【学習した内容】<br>
・宣言的UI　(InterfaceBuilderなしで画面を作成)<br>
・UIへのAttribute付与(グラデーション、影、文字の強弱など）<br>
・UIへのアニメーション付与(ホーム画面読み込み時、ウイルスマークが転がる)<br>
・ライブラリ Cocoapodsの利用<br>
・シングルトン実装<br>
・Firebaseを用いたチャット機能の実装<br>
・画像素材の探し方(アプリで使用している画像はすべてフリー素材/flaticon)<br>

