jQuery ->
  $('#bargain_booze_export_form').submit ->
    $('input:submit').attr('value', 'Working...')
    $('input:submit').attr('disabled', true)
