#/bin/bash
# Yosan_Data.sh  2019.4.13
# エラーが発生したら処理中止
set -e
###########################################################################
# このスクリプトについて
# 概要
# 企業会計システムから出てくるCSVデータの款項目データが一部省略され、使いにくいことから整形する

# 処理フロー
# nlで行番号を付加
# gawk
# 1.BEGIN $a,$b,$c1を初期化
# 2.行2列1文字目のみスペースならa[NR,1]にデータを入れる。
# 3.行2列2文字目までスペースならa[NR,2]にデータを入れる。
# 4.行2列3文字目までスペースならa[NR,3]にデータを入れる。
# 一時ファイル出力
# grepで2列空白以外を抽出
# sort

# 使い方
# !!このディレクトリに移動後、右クリックで git bash起動後、 $ ./Yosan_Data.shを入力

###########################################################################
# 処理するファイルの設定
MEISAI_FILE=meisai.csv
#フィールド
# "1款項目名称,"2税込金額"

# ディレクトリ
DIRECTORY=/Users/yaskom2002/
###########################################################################
# 関数定義

# koumoku_bunkatsu 1列目を列頭の空白数により、3列に分割する。
# main処理で１列目頭の空白数で分離して配列に読み込む。gsubで空白削除
# end処理で空白フィールドに直近データを入れる。

koumoku_bunkatsu(){
  gawk 'BEGIN { FS=","; OFS=","; } 
	NR >0 {
	    switch($2){
	    case /^\s[0-9]+[^a-zA-Z0-9]+/ :	#2列目第１文字空白
	      gsub(/ /,"",$2); 
	      a[NR,1]=$2 ; a[NR,2]=""; a[NR,3]=""; a[NR,4]=$3; a[NR,5]=$4;
	      break

	    case /^\s{2}[0-9]+[^a-zA-Z0-9]+/ :	#2列目第2文字まで空白
	      gsub(/ /,"",$2); 
	      a[NR,1]=""; a[NR,2]=$2 ; a[NR,3]=""; a[NR,4]=$3; a[NR,5]=$4;
	      break

	    case /^\s{3}[0-9]+[^a-zA-Z0-9]+/ :	#2列目第3文字まで空白	
	      gsub(/ /,"",$2); 
	      a[NR,1]=""; a[NR,2]=""; a[NR,3]=$2; a[NR,4]=$3; a[NR,5]=$4;
	      break
	    }
        }
	END {

	    # 2列目処理 空白列に１つ前のデータを入れる
	    retsu=2
	    koumoku2 = a[1,retsu];
	    for(p = 1; p <= NR; p++){

		if((a[p,retsu-1] == "") && (a[p,retsu] == "")) {
		    a[p,retsu] = koumoku2;
		} else {
		    koumoku2 = a[p,retsu];
		    koumoku3 = "";
		}
	    }

	    # 1列目処理 空白列に１つ前のデータを入れる
	    retsu=1
	    koumoku1 = a[1,retsu];
	    for(p = 1; p <= NR; p++){

		if((a[p,retsu-1] == "") && (a[p,retsu] == "")) {
		    a[p,retsu] = koumoku1;
		} else {
		    koumoku1 = a[p,retsu];
		    koumoku2 = "";
		    koumoku3 = "";
		}
	    }

            # 1行あたりのフィールド数
	    data_kensu=4;

            # 1行内データを配列に入れる　１月分データ件数でループ	
	    for(k = 1;k <= NR; k++){
	       print a[k,1],a[k,2],a[k,3],a[k,4],a[k,5];
            }
    	}'
}

# 処理作業


# システムから出力された生データの漢字コードをUTF8変換→行番号付きで出力
# koumoku_fukaで行頭空白数で項目を分けて、一時ファイル出力
# 一時ファイルで１列目空白行を抽出、
# →漢字コードをSJIS変換→tmp1.csv作成; cutで表示項目指定

cat ${DIRECTORY}${MEISAI_FILE} | nkf -w8 | sed '/^$/d' |nl -s"," \
    | koumoku_bunkatsu |sort \

# | LANG=C sort -t "," -k 7,7 -k 22,22 -k 26,26 -k 28,28 | cut -d "," -f 7-15,18,20,21,22,26-29 | nkf -s > tmp1.csv

# 行末尾に款項目情報を付加
# 正規表現チェックサイト　https://rubular.com/が役に立った


