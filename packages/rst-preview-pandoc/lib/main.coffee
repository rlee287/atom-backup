url = require 'url'

MarkdownPreviewView = null # Defer until used
renderer = null # Defer until used

createMarkdownPreviewView = (state) ->
  MarkdownPreviewView ?= require './markdown-preview-view'
  new MarkdownPreviewView(state)

isMarkdownPreviewView = (object) ->
  MarkdownPreviewView ?= require './markdown-preview-view'
  object instanceof MarkdownPreviewView

atom.deserializers.add
  name: 'MarkdownPreviewView'
  deserialize: (state) ->
    createMarkdownPreviewView(state) if state.constructor is Object

module.exports =
  config:
    pandocPath:
      type: 'string'
      default: 'pandoc'
    pandocOpts:
      type: 'string'
      default: '-fmarkdown -thtml --webtex'
    liveUpdate:
      type: 'boolean'
      default: true
    openPreviewInSplitPane:
      type: 'boolean'
      default: true
    grammars:
      type: 'array'
      default: [
        'source.gfm'
        'source.litcoffee'
        'text.html.basic'
        'text.plain'
        'text.plain.null-grammar'
        'gfm.restructuredtext'
        'text.restructuredtext'
        'source.gfm.restructuredtext'
        'text.restructuredtext source.gfm.restructuredtext'
        'text.tex.latex'
      ]
    scrollWithEditor:
      type: 'boolean'
      default: true

  activate: ->
    atom.commands.add 'atom-workspace',
      'rst-preview-pandoc:toggle': =>
        @toggle()
      'rst-preview-pandoc:copy-html': =>
        @copyHtml()

    previewFile = @previewFile.bind(this)
    atom.commands.add '.tree-view .file .name[data-name$=\\.markdown]', 'rst-preview-pandoc:preview-file', previewFile
    atom.commands.add '.tree-view .file .name[data-name$=\\.md]', 'rst-preview-pandoc:preview-file', previewFile
    atom.commands.add '.tree-view .file .name[data-name$=\\.mdown]', 'rst-preview-pandoc:preview-file', previewFile
    atom.commands.add '.tree-view .file .name[data-name$=\\.mkd]', 'rst-preview-pandoc:preview-file', previewFile
    atom.commands.add '.tree-view .file .name[data-name$=\\.mkdown]', 'rst-preview-pandoc:preview-file', previewFile
    atom.commands.add '.tree-view .file .name[data-name$=\\.ron]', 'rst-preview-pandoc:preview-file', previewFile
    atom.commands.add '.tree-view .file .name[data-name$=\\.txt]', 'rst-preview-pandoc:preview-file', previewFile
    atom.commands.add '.tree-view .file .name[data-name$=\\.rst]', 'rst-preview-pandoc:preview-file', previewFile
    atom.commands.add '.tree-view .file .name[data-name$=\\.tex]', 'rst-preview-pandoc:preview-file', previewFile

    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      return unless protocol is 'rst-preview-pandoc:'

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      if host is 'editor'
        createMarkdownPreviewView(editorId: pathname.substring(1))
      else
        createMarkdownPreviewView(filePath: pathname)

  toggle: ->
    if isMarkdownPreviewView(atom.workspace.getActivePaneItem())
      atom.workspace.destroyActivePaneItem()
      return

    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    console.warn(editor.getGrammar().scopeName)
    console.warn(editor.getGrammar().name)
    console.warn(atom.config.get('rst-preview-pandoc.grammars'))
    grammars = atom.config.get('rst-preview-pandoc.grammars') ? []
    return unless editor.getGrammar().scopeName in grammars

    if editor.getGrammar().name is 'reStructuredText'
      # change option to reStructuredText
      atom.config.set('rst-preview-pandoc.pandocOpts', '-frst -thtml --webtex')
    else if editor.getGrammar().name is 'GitHub Markdown'
      atom.config.set('rst-preview-pandoc.pandocOpts', '-fmarkdown_github -thtml --webtex')
    else if editor.getGrammar().scopeName is 'text.tex.latex'
      atom.config.set('rst-preview-pandoc.pandocOpts', '-flatex -thtml --webtex')
    else
      atom.config.set('rst-preview-pandoc.pandocOpts', '-fmarkdown -thtml --webtex')

    console.warn(atom.config.get('rst-preview-pandoc.pandocOpts'))

    @addPreviewForEditor(editor) unless @removePreviewForEditor(editor)

  uriForEditor: (editor) ->
    "rst-preview-pandoc://editor/#{editor.id}"

  removePreviewForEditor: (editor) ->
    uri = @uriForEditor(editor)
    previewPane = atom.workspace.paneForURI(uri)
    if previewPane?
      previewPane.destroyItem(previewPane.itemForURI(uri))
      true
    else
      false

  addPreviewForEditor: (editor) ->
    uri = @uriForEditor(editor)
    previousActivePane = atom.workspace.getActivePane()
    options =
      searchAllPanes: true
    if atom.config.get('rst-preview-pandoc.openPreviewInSplitPane')
      options.split = 'right'
    atom.workspace.open(uri, options).then (markdownPreviewView) ->
      if isMarkdownPreviewView(markdownPreviewView)
        previousActivePane.activate()

  previewFile: ({target}) ->
    filePath = target.dataset.path
    return unless filePath

    for editor in atom.workspace.getTextEditors() when editor.getPath() is filePath
      @addPreviewForEditor(editor)
      return

    atom.workspace.open "rst-preview-pandoc://#{encodeURI(filePath)}", searchAllPanes: true

  copyHtml: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    renderer ?= require './renderer'
    text = editor.getSelectedText() or editor.getText()
    renderer.toHTML text, editor.getPath(), editor.getGrammar(), (error, html) =>
      if error
        console.warn('Copying Markdown as HTML failed', error)
      else
        atom.clipboard.write(html)
