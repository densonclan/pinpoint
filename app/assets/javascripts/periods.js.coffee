jQuery ->

  create_exception_path = (data) ->
    "/order_exceptions?order_exception%5Border_id%5D=#{data['order_id']}&order_exception%5Bperiod_id%5D=#{data['period_id']}"

  delete_exception_path = (data) ->
    "/order_exceptions/#{data['id']}"

  $('#review-orders-table').on 'click', 'a.order-exception', ->
    a = $(this)
    $.ajax {
      method: if a.hasClass('skipped') then 'DELETE' else 'POST'
      url: a.attr('href')
      dataType: 'JSON'
      success: (data) ->
        a.toggleClass('skipped')
        if a.hasClass('skipped')
          a.attr('href', delete_exception_path(data))
        else
          a.attr('href', create_exception_path(data))
    }
    return false