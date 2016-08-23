jQuery ->
  
  append_address_attribute = (attr) ->
    if attr && attr.length > 0
      $('.existing-address').append attr
      $('.existing-address').append "<br/>"

  populateForm = (data) ->

    $('form#copy-address input[name=_method]').remove()
    $('form#copy-address').prepend '<input type="hidden" name="_method" value="put" />' if data['id'] != null
    $('form#copy-address').attr 'action', "/addresses/#{data['id']}"
    $('.existing-address').html ""
    $.each ['title', 'full_name', 'business_name', 'first_line', 'second_line', 'third_line', 'postcode', 'city', 'county', 'phone_number', 'email'], (i, attr) ->
      append_address_attribute data[attr]

  address_label_from_data = (row) ->
    "#{row['full_name']}, #{row['first_line']}, #{row['city']}"

  $('#lookup_address').autocomplete {
    source: $('#lookup_address').data('search-path')
    response: (event, ui) ->
      $(ui.content).each (i, row) ->
        row['value'] = row['id']
        row['label'] = address_label_from_data(row)
    focus: (event, ui) ->
      $('#lookup_address').val ui.item['label']
      populateForm ui.item
      false
    select: (event, ui) ->
      $('#existing_address').val ui.item['value']
      false
  }

  $('#address_copy').on 'change', ->
    $('#copy-address').show()
    $('form#new_address').hide()
  $('#address_new').on 'change', ->
    $('#copy-address').hide()
    $('form#new_address').show()
