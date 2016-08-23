jQuery ->

  selected_postcodes_list = (a) ->
    ids = a.prev().val().split(',')
    list = $.map a.text().split(', '), (txt, i) -> "<li data-id='#{ids[i]}'>#{txt}</li>"
    list.join('')

  $('.postcode-popup').on 'click', ->
    $('#postcode_search').data('distribution', $(this).attr('id'))
    $('#selected-postcodes').html if $(this).text() == 'none' then '' else selected_postcodes_list($(this))
    true

  selected_postcode_ids = ->
    $('#selected-postcodes li').map (i, li) ->
      $(li).data('id')

  selected_postcodes = ->
    $('#selected-postcodes li').map (i, li) ->
      $(li).text()

  selected_postcodes_label = ->
    a = selected_postcodes().toArray()
    if a.length == 0 then 'none' else a.join(', ')

  $('#save-postcodes').on 'click', ->
    a = $("##{$('#postcode_search').data('distribution')}")
    a.text selected_postcodes_label()
    a.prev().val selected_postcode_ids().toArray().join(',')
    true

  $('#selected-postcodes').on 'click', 'li', ->
    $(this).remove()

  $('.typeahead-postcode').autocomplete
    source: '/postcode_sectors/search.json'
    appendTo: '#postcode_search'
    focus: (event, ui) ->
      $('.typeahead-postcode').val(ui.item.label)
      false
    select: (event, ui) ->
      $('.typeahead-postcode').val('')
      $('#selected-postcodes').append($('<li />').data('id', ui.item.value).text(ui.item.label))
      false

  $('#postcode-form').on 'submit', ->
    false