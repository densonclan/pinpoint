jQuery ->
  if $("#export_template_value").length > 0
    $("#export_template_value").select2
      tags: $('#order_fields').val().split(',')

    $("#export_template_value").select2("container").find("ul.select2-choices").sortable
      containment: 'parent'
      start: -> $("#export_template_value").select2("onSortStart")
      update: -> $("#export_template_value").select2("onSortEnd")

  move_matching_options_to_select = (match) ->
    $('select#hidden_option option').each (i, option) ->
      if $(option).text().match match
        $('select#option').append option

  move_shown_options_back_to_hidden = ->
    $('select#hidden_option').append $('select#option option').remove()

  update_options_list_matching_selected_period = ->
    move_shown_options_back_to_hidden()
    company = $('select#period option:selected').text().split(' ')[0]
    move_matching_options_to_select "(#{company})"

  if $('form#order-exporter select#hidden_option').length == 1
    $('form#order-exporter select#period').on 'change', ->
      update_options_list_matching_selected_period()

    update_options_list_matching_selected_period()

  if $('#running_order_options').length == 1

    selectedRunningOrder = ->
      $('#running_order_options li').map (i, li) ->
        $(li).text()
      .get()

    setRunningOrder = ->
      $('#running_order').val selectedRunningOrder().join ','

    $( "#running_order_options" ).sortable
      stop: -> setRunningOrder()

    setRunningOrder()