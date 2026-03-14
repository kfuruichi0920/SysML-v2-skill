---
name: sysmlv2-model-generator
description: "Generate SysML v2 models from a user prompt or from the contents of a specified file. Use when the user asks to create SysMLv2 from requirements, design text, ADRs, use cases, constraints, Markdown, or other text documents. Supports プロンプト入力, ファイル指定, SysMLv2モデル生成, PIM/PSM同時生成, トレース付き出力, and review-ready results with assumptions and TBD markers."
---

# SysMLv2 Model Generator

## 目的

この skill は、ユーザーが与えた**自然言語プロンプト**または**指定ファイルの内容**を読み取り、
レビュー可能な **SysML v2 テキストモデル**を生成するために使う。

このワークスペースでは、`report/` 配下の方法論に合わせて、以下を重視する。

- 意味保存を優先する
- A/B/C 三層の観点を意識する
- PIM/PSM を同時に捉える
- 根拠・トレース・未確定事項を明示する
- 人間レビュー前提の「提案」として出力する

## 想定入力

次のいずれかを入力源として扱う。

1. **プロンプト入力**
   - チャット本文に記載された要求、設計説明、ユースケース、制約、判断理由など
2. **指定ファイル入力**
   - ワークスペース内の `*.md` `*.txt` `*.sysml` `*.kerml` など、読み取り可能なテキストファイル
   - 長文の場合は、見出しまたは意味ブロック単位で分割して処理する

入力が Word / Excel / PowerPoint / PDF のような非テキスト原本で、そのまま読めない場合は、
まず抽出済みテキストまたは Markdown を用意してから処理する。

## 最初に行うこと

### 1. 入力源を確定する

- ユーザーが**本文で与えたテキスト**を使うのか
- **ファイルを読む**のか
- 両方を併用するのか

を明確にする。

### 2. 目的と出力粒度を決める

可能であれば次を明確にする。

- 対象スコープ: 要求のみ / PIM / PSM / 要求+PIM+PSM
- 出力単位: 1パッケージ / 複数パッケージ / 単一ブロック
- 欲しい要素: `requirement`, `constraint`, `part`, `interface`, `port`, `action`, `state` など
- 欲しい関係: `satisfy`, `refine`, `allocate`, `dependency`, `connector`, `binding connector`, `verify` など

ユーザー指定が曖昧でも、最低限の前提を置いて作業を進めてよい。ただし**推測は明示**する。

## 実行ワークフロー

### 1. 入力を読む

- ファイル指定なら対象ファイルを読む
- 長文なら見出しや意味ブロックごとに分割する
- 原文の意味を壊さずに要点を抽出する

### 2. 用語を固定する

- 重要語、略語、曖昧語、同義語候補を抽出する
- 可能なら正規形を決める
- 不確かな語は `<T.B.D>` または「要確認」として残す

### 3. A/B/C 観点で整理する

- **A 層**: 要求、制約、ドメイン概念、受入条件
- **B 層**: 設計判断、責務配賦、採用理由、トレードオフ、前提
- **C 層**: SysMLv2 で表す構造、I/F、振る舞い、状態、検証要素

### 4. PIM/PSM を同時に切り分ける

- **PIM** には、論理責務、論理インターフェース、意味的状態や論理制約を置く
- **PSM** には、実行構造、実行 I/F、実行制約、運用条件を置く
- 実装技術に依存する詳細へ踏み込みすぎない

### 5. SysMLv2 要素へ写像する

少なくとも必要に応じて以下を使う。

- 構造: `package`, `part def`, `part`, `item def`, `interface def`, `port def`
- 振る舞い: `action def`, `state def`, `occurrence def`
- 要求/制約: `requirement def`, `requirement`, `constraint def`
- 関係: `satisfy`, `refine`, `allocate`, `dependency`, `connector`, `binding connector`, `verify`

### 6. トレースを保持する

可能な範囲で以下を残す。

- 入力文や章節との対応
- 要求 ↔ PIM ↔ PSM の対応
- A/B/C 間の説明経路
- 欠落・未確定・要レビュー箇所

### 7. 構文と妥当性を自己点検する

生成前後に次を確認する。

- 命名が一貫しているか
- 1つのファイルに過剰な責務を詰め込んでいないか
- package 名と主要要素の対応が自然か
- import や参照の前提が明示されているか
- 不必要な幻覚要素を作っていないか

## 出力ルール

回答には、必要に応じて次を含める。

1. **入力の理解要約**
2. **前提・仮定・未確定事項**
3. **抽出した要求/判断/構造の要約**
4. **SysMLv2 モデル本体**
5. **レビュー観点**

SysMLv2 コードを出すときは、次を守る。

- 1つの主要 `package` を中心に構成する
- 名前は用語辞書に合わせて安定化する
- コメントで根拠や要確認点を残してよい
- 断定できない内容はモデルに埋め込まず、注記へ逃がす

## 推奨出力順

### 小規模入力

- 要約
- 前提
- SysMLv2 コード
- レビュー観点

### 中〜大規模入力

- 要約
- 用語正規化メモ
- A/B/C または 要求/PIM/PSM の整理
- SysMLv2 コード
- トレースと未確定事項
- 次に分割して処理すべきブロック

## 禁止・注意事項

- 原文にない重要な要件を勝手に追加しない
- A 層の意味を、実装都合で書き換えない
- B 層の判断を飛ばして C 層だけを捏造しない
- 実装コードレベルの詳細を、根拠なく PSM に持ち込まない
- 不明点を黙って埋めず、`<T.B.D>`・要確認・仮定として明示する

## このワークスペースで参照すべき資料

- `report/第4章　SWE適用に向けた要件定義.md`
- `report/第5章　SWE適用の方法論.md`
- `report/第6.1章 入力文書のテキスト化.md`
- `report/第6.2章 用語辞書の作成.md`
- `report/第6.3章 SysMLv2モデル変換仕様定義.md`
- `report/第6.4章 SysMLv2 APIサーバ構築、クエリ設定.md`
- `references/generation-workflow.md`
- `templates/source-intake-template.md`
- `templates/output-template.sysml`

## 付属テンプレートの使い分け

- 入力条件を整理したいときは `templates/source-intake-template.md`
- 出力の骨格を揃えたいときは `templates/output-template.sysml`
- 方法論の要点を再確認したいときは `references/generation-workflow.md`

## レビュー観点

最終出力前に、少なくとも次を確認する。

- 要求、制約、責務、根拠が抜けていないか
- PIM と PSM の混線がないか
- SysMLv2 の要素選択が過不足ないか
- 要確認事項が明示されているか
- レビュー担当者が原文へ戻れるだけの根拠が残っているか
