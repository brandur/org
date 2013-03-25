initSyntax = ->
  $.SyntaxHighlighter.init 
    'lineNumbers': false 
    #'theme': 'sunburst' 
    'wrapLines': true 

$(document).ready ->
  $('a[data-pjax]').pjax
    'timeout': 2000
  initSyntax()

$(document).on 'pjax:end', ->
  initSyntax()
