# SysMLv2モデル生成 入力整理テンプレート

以下を埋めると、プロンプト入力でもファイル入力でも生成指示が安定する。

## 入力源

- source_type: `prompt` | `file` | `mixed`
- file_path: 
- source_summary: 

## 文書メタデータ

- document_id: 
- document_version: 
- section_scope: 
- source_anchor_hint: 

## 生成したい範囲

- target_scope: `requirements` | `PIM` | `PSM` | `requirements+PIM+PSM`
- output_unit: `single-package` | `multi-package` | `single-block`
- target_package_name: 

## 優先したい要素

- requirement_elements: 
- structural_elements: 
- behavioral_elements: 
- trace_relations: 

## 用語ルール

- preferred_terms: 
- aliases_to_merge: 
- forbidden_terms: 

## 制約・方針

- must_preserve_constraints: 
- assumptions_allowed: yes / no
- include_tbd_markers: yes / no
- implementation_detail_level: low / medium / high

## 補足

- existing_model_to_align_with: 
- review_focus: 
- notes: 
