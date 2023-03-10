WorkingFloor2.fx ver0.0.8

オフスクリーンレンダを使った床面鏡像描画，大いに床に仕事をさせます。
以前作成したWorkingFloor.fxをオフスクリーンレンダを利用して再構築しました。
その結果，半透明床を用いずに通常のステージで床面鏡像描画が出来るようになりました。
また地面影越しに見ても透過して描画出来るようになりました。Mirror.fxとは異なる手法で
床面鏡像を作成しており，足下をズームアップしても鏡像が粗くなることがありません。
舞力介入P氏のMirror.fx, full.fxを改変して作成しました。


・使用方法
(1)WorkingFloor2.xをMMDにロードします。
(2)デフォルトで鏡像化されるモデルは 全てのPMD・PMX,および.vec になっています。
   個別に適用したい場合は以下の方法でfxファイルをそれぞれ設定します。

   ｢MMEffect｣→｢エフェクト割当｣→｢WorkingFloorRT｣タブを開き、鏡像化したいオブジェクトを選択して、WF_Object.fxsubを適用する。
   また｢WorkingFloorRT｣タブで鏡像化しないモデルは非表示にする。

(3)MMDのアクセサリパラメータで以下の変更を行いキーフレーム登録してください。
    Tr：床面鏡像の透過度
    その他のパラメータで床の描画範囲を設定します。
    エフェクトをoffにした時のWorkingFloor2.xの白い板ポリ内が描画範囲になります。
(4)描画順序は，背景ステージ→WorkingFloor2.x→その他のオブジェクトの順に設定してください。


・MikuMikuMovingについて
このエフェクトはMikuMikuMovingにも対応しています。
WorkingFloor2.fxを直接MikuMikuMovingにロードしてご利用下さい。


・応用
WorkingFloor2.xを別形状のモデルに置き換えることでステージの形状に合わせて鏡像描画する範囲を
制限することが出来ます。


・注意点
一部のグラフィックボードでモデルの鏡像が正常に描画されない(モデルが黒または白になる)ことが
あります。この場合、WorkingFloor2.fxの先頭パラメータFLG_EXCEPTIONを変更してご利用ください。


※このFXファイルはMMEver0.33以降でないと正しく動作しません。


・更新履歴
v0.0.8  2013/11/17  一部のグラボで鏡像モデルが正常に描画されない不具合への対応
v0.0.7  2013/7/05   MMEシェーダを新しいバージョン(v0.33以降)仕様にした(PMXの材質モーフ､サブTex等に対応)
                    MikuMikuMovingの対応
v0.0.6  2012/9/10   x64版の標準ミップマップテクスチャ対応,内部コードの整理,鏡像変換方法の簡素化
v0.0.5  2011/9/28   マスク処理を使わずに描画できるように改良(レンダリング負荷軽減)
v0.0.4  2011/7/30   α値0.99で両面描画設定している材質のマスク処理法を変更
                    非セルフシャドウ描画でトーンシェードが正しく処理されない不具合の修正
                    セルフシャドウのテクスチャとアクセサリ描画時の不具合に関する修正
v0.0.3  2011/7/01   スフィアマップ使用材質でα値が正しく描画できない不具合を修正,デフォルトでPMX描画を追加
v0.0.2  2011/4/11   モデル・アクセの床下に潜った部位の鏡像が非表示になるように修正
v0.0.1  2011/1/15   初回版公開


・免責事項
ご利用・改変・二次配布は自由にやっていただいてかまいません。連絡も不要です。
ただしこれらの行為は全て自己責任でやってください。
このプログラム使用により、いかなる損害が生じた場合でも当方は一切の責任を負いません。


by 針金P
Twitter : @HariganeP


