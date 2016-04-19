$(document).ready ->
  $('a[data-pjax]').pjax
    'timeout': 2000
  hljs.initHighlightingOnLoad()

$(document).on 'pjax:end', ->
  hljs.initHighlightingOnLoad()
