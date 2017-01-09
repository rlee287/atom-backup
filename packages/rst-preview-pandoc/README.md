# reStructuredText Preview package

Show the pandoc-rendered HTML markdown to the right of the current editor using
`ctrl-shift-e`.

Live Update scrolls to cursor position when editing. You can also toggle scrolling preview together with editor (like StackEdit for example).



It can be activated from the editor using the `ctrl-shift-e` key-binding and is
currently enabled for `.markdown`, `.md`, `.mdown`, `.mkd`, `.mkdown`, `.ron`, `.txt`, `.tex` and `.rst` files.

For a better way to preview math than default `--webtex`, you can try a pandoc filter like this one: <https://gist.github.com/lierdakil/6a95278d02256a74a0fc>

## Dependency

This package use `pandoc` library(not atom package) and `language-reStructuredText` package. So, install each.

### pandoc

install and set PATH. **This is not atom package.**

http://johnmacfarlane.net/pandoc/installing.html

### language-reStructuredText

`language-reStructuredText` is atom package. Please install and update before use this. **v0.9.0 or later is required.**

https://atom.io/packages/language-restructuredtext

## Usage

Keybind is `ctrl-shift-e`.

Or, Packages -> reStructuredText Preview Pandoc -> Toggle Preview

## Test

Use pandoc library's test files(`.rst`, `.jpg`).

https://github.com/jgm/pandoc/tree/master/tests

`rst-reader.rst` may be good.

https://github.com/jgm/pandoc/blob/master/tests/rst-reader.rst

## Unreadable characters (For Japanese)
atom のバージョンによっては日本語が文字化けするようです。
その場合はエディタ、Previewのそれぞれで、日本語フォントを設定してください。

### エディタ側
Preference -> Settings を開き、`Font Family` に`takaoGothic`などの日本語のFontを指定してください。  
![editor_setting.png](https://github.com/tohosokawa/rst-preview-pandoc/raw/rst/image/editor_setting.png)

### Preview側
Preference -> Packages -> rst-preview-pandoc から設定画面を開き、
下記の画像のように `View Code` からソースコードを開いてください。
![setting.png](https://github.com/tohosokawa/rst-preview-pandoc/raw/rst/image/setting.png)

`rst-preview-pandoc/styles/markdown-preview.less` の３行目に日本語のフォントを追加してください。

![source.png](https://github.com/tohosokawa/rst-preview-pandoc/raw/rst/image/source.png)
