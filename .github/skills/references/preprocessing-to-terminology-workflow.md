# Preprocessing to Terminology Integrated Workflow

この資料は、`document-textualizer` と `terminology-dictionary-builder` をつなぐための**統合ワークフロー資料**である。

目的は、入力文書の意味保存テキスト化から、用語辞書の正規化・曖昧語分離・A/B/C 層別整理までを、同じ保存則のもとで一貫して実施できるようにすることである。

## 1. 対象範囲

この統合ワークフローは、次のような文書を対象とする。

- 要求仕様書
- ユースケース記述
- 設計書
- ADR
- 試験仕様書
- 運用制約書
- 議事録

対象形式は、Markdown、プレーンテキスト、HTML、PDF/Office 由来テキストを含む。

## 2. 全体の考え方

前処理と辞書化は別作業ではあるが、実際には次の流れで一体として扱う。

1. 原文から意味保存を崩さずに情報を抽出する
2. 文単位・構造単位へ正規化する
3. 用語候補とその出現根拠を保持する
4. 正規形、別名、略語、曖昧語を整理する
5. A/B/C 三層およびトレース監査で再利用できる辞書へ固定する

つまり、`document-textualizer` は**意味を壊さず渡す工程**、`terminology-dictionary-builder` は**意味境界を固定する工程**として連携する。

## 3. 工程の対応関係

| 工程 | 主担当 skill | 主な目的 | 主な成果物 |
| --- | --- | --- | --- |
| 文書識別 | `document-textualizer` | 原文書 ID・版・入力元の固定 | 文書プロファイル |
| 生テキスト抽出 | `document-textualizer` | 逐語的テキストの確保 | 生テキスト |
| 正規化・構造化 | `document-textualizer` | 一文一義・構造保持・原位置保持 | 正規化テキスト、構造メタデータ |
| 候補語抽出 | `document-textualizer` | 用語候補の洗い出し | 用語候補一覧 |
| 用語統合 | `terminology-dictionary-builder` | 正規形、別名、略語の整理 | 正規化用語辞書 |
| 曖昧語分離 | `terminology-dictionary-builder` | 多義語・汎用語の警告と分離 | 曖昧語警告一覧 |
| 層別整理 | `terminology-dictionary-builder` | A/B/C の主対象語整理 | 層別主要語一覧 |
| レビュー確定 | 両方 | 根拠・意味・分類の妥当性確認 | 確定版辞書・差分記録 |

## 4. ハンドオフ条件

`document-textualizer` から `terminology-dictionary-builder` へ渡す前に、最低限次が揃っていることを確認する。

### 必須

- `document_id`
- `document_version`
- `section_id`
- `sentence_id`
- `source_anchor`
- 正規化テキスト
- 文単位リスト
- 用語候補一覧

### 強く推奨

- `layer_hint`
- `review_status`
- 図表・脚注・注記の扱いメモ
- 正規化判断のレビュー印

これらが欠けると、辞書側で**根拠追跡**や**意味境界確認**が不安定になる。

## 5. 推奨入出力のつなぎ方

### 5.1 前処理側の出力

前処理では少なくとも次を揃える。

| 成果物 | 用途 |
| --- | --- |
| 生テキスト | 原文再確認 |
| 正規化テキスト | 辞書作成・後続分析入力 |
| 文単位リスト | 用語根拠文の追跡 |
| 構造メタデータ | 章節、表、注、図参照の復元 |
| 用語候補一覧 | 辞書初期候補 |

### 5.2 辞書側の入力

辞書化では、前処理成果物を次のように受け取る。

| 入力 | 辞書化での使い方 |
| --- | --- |
| 正規化テキスト | 文脈確認 |
| 文単位リスト | `source_sentence_ids` の根拠確保 |
| 用語候補一覧 | 初期抽出集合 |
| 構造メタデータ | 同形異義語の文脈分離補助 |
| `layer_hint` | `layer_scope` の初期仮説 |

## 6. `layer_hint` から `layer_scope` への橋渡し

前処理では文単位に `layer_hint` を付け、辞書化では用語単位に `layer_scope` を付ける。
この 2 つは同じではないが、次のように橋渡しできる。

| 前処理の `layer_hint` | 辞書化の `layer_scope` での扱い |
| --- | --- |
| A | 要求意図、規範、制約、ドメイン概念の候補 |
| B | 設計判断、責務、根拠、採用理由の候補 |
| C | 構造、I/F、状態、実装・試験要素の候補 |
| 複数候補 | 用語単位で主対象を再判定し、注記で補足 |

注意点は、**文の層**と**用語の層**は一致しないことがある点である。
たとえば B 層の設計判断文に C 層構造名が出ることは普通にある。ここは機械的に移送せず、辞書化段階で見直す。

## 7. 用語抽出から辞書登録までの手順

### 7.1 候補抽出

- 重要語
- 略語
- 専門語
- 曖昧語
- 汎用語 + 対象語の複合表現

を候補として集める。

### 7.2 候補の整理

- 表記揺れをまとめる
- 略語と正式名称を対応づける
- 英語名がある場合は対応づける
- 同義語らしきものを仮統合する

### 7.3 意味境界の確認

- 1 用語 1 意味になっているか
- 複数意味があれば分離すべきか
- 汎用語単独では危険でないか
- 定義を短く安定して書けるか

### 7.4 根拠づけ

- `source_sentence_ids` を必ず付ける
- 可能なら `section_id` や `source_anchor` も参照できるようにする
- 統合理由・分離理由が弱い場合は `status: 仮登録` とする

### 7.5 レビュー確定

- 同義語統合の妥当性
- 曖昧語分離の妥当性
- A/B/C 主対象の妥当性
- SysMLv2 命名とクエリ別名に使って問題ないか

を確認する。

## 8. ループバック条件

辞書化中に次の問題が見つかったら、前処理へ戻る。

- 文分割が粗く、どの文が根拠か特定できない
- 構造メタデータが不足し、同形異義語を分離できない
- 図表由来の意味が落ちていて定義が定まらない
- 略語の初出が不明で正式名称を確定できない
- OCR 誤認識により候補語自体が疑わしい

つまり、辞書で解決できない問題を辞書に押し込めない。必要なら `document-textualizer` 側の成果物を修正する。

## 9. 品質ゲート

### ゲート 1: 前処理完了判定

- 要求モダリティが保持されている
- 文 ID が一意である
- 原位置へ遡及できる
- 用語候補一覧がある
- 明らかな OCR 誤りが印付きで残っている

### ゲート 2: 辞書初版判定

- `preferred_label` が定義されている
- `aliases` が整理されている
- `source_sentence_ids` が付いている
- `layer_scope` が付いている
- 曖昧語が警告として切り出されている

### ゲート 3: 統合完了判定

- 1 用語 1 意味の原則を満たす
- 同義語統合で意味差を潰していない
- 汎用語の単独使用が警告されている
- A/B/C およびクエリ支援に使える
- 未確定事項が明示されている

## 10. 成果物パッケージ例

統合ワークフローの成果物は、次のような束で管理すると扱いやすい。

- `normalized-text.md`
- `sentence-list.md` または `sentence-list.csv`
- `structure-metadata.md` または `structure-metadata.json`
- `term-candidates.md`
- `terminology-dictionary.md`
- `ambiguity-warnings.md`
- `review-notes.md`

## 11. 推奨レビュー観点

### 前処理レビュー

- 原文意味が壊れていないか
- 但し書きや条件が落ちていないか
- 図表・注記情報が欠落していないか
- 候補語抽出に必要な語が拾えているか

### 辞書レビュー

- 定義が循環していないか
- 同義語統合が過剰でないか
- 曖昧語が未分離でないか
- `preferred_label` が SysMLv2 命名へ流用しやすいか
- クエリ支援時の別名検索に耐えられるか

## 12. 典型的な失敗パターン

- 文書正規化で語尾だけ整えて、要求モダリティまで変えてしまう
- 文単位リストはあるが `source_anchor` がなく、監査できない
- 用語候補一覧を作らず、辞書化で再抽出してズレる
- `layer_hint` をそのまま `layer_scope` にして誤分類する
- 「仕様」「要求」「制約」をまとめてしまい意味境界を壊す
- 汎用語をそのまま正規形にして SysMLv2 名称が弱くなる

## 13. 実行順の推奨

1. `document-textualizer` で原文を意味保存テキストへ変換する
2. 文単位リスト、構造メタデータ、用語候補一覧を揃える
3. ハンドオフ条件を確認する
4. `terminology-dictionary-builder` で正規形・別名・曖昧語を整理する
5. A/B/C 層別主要語と警告一覧を作る
6. 必要なら前処理へ戻って文分割や構造情報を補強する
7. 確定版辞書を、SysMLv2 変換やクエリ支援へ渡す

## 14. 併用する資料

- `document-textualizer/references/textualization-workflow.md`
- `terminology-dictionary-builder/references/terminology-workflow.md`
- `document-textualizer/templates/source-intake-template.md`
- `document-textualizer/templates/textualization-output-template.md`
- `terminology-dictionary-builder/templates/terminology-intake-template.md`
- `terminology-dictionary-builder/templates/terminology-dictionary-template.md`

この資料は、前処理と辞書化の**橋渡し基準**として使う。個別 skill の詳細手順は、それぞれの `SKILL.md` と参照資料を正本とする。
