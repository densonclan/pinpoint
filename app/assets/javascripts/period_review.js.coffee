jQuery ->

  ajax_intercept_pagination_links = (div) ->
    $(div).on 'click', '.pagination a, th a', ->
      $.ajax {
        url: $(this).attr('href'),
        method: 'GET',
        dataType: 'HTML'
        success: (html) ->
          $(div).html html
      }
      false

  $('#review-order-search-form form').on 'submit', ->
    $.ajax {
      url: $(this).attr('action'),
      method: 'GET',
      dataType: 'HTML',
      data: $(this).serialize(),
      success: (html) ->
        $('#review-orders-table').html html
    }
    false

  ajax_intercept_pagination_links '#review-orders-table'
  ajax_intercept_pagination_links '#review-stores-table'