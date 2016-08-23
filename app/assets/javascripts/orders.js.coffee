jQuery ->
  $('#order_option.filter').on 'change', ->
    window.location = "#{$('#order_option.filter').data('url')}?order_option=#{$(this).val()}"

  sum_order_total_quantities = ->
    val = 0
    $('.total-quantity-input').each ->
      val += Number($(this).val())
    val

  update_order_totals = ->
    $('#sum-order-total-quantity').text sum_order_total_quantities()

  if $('form#order-form').length == 1
    $('.total-quantity-input').on 'keyup', ->
      update_order_totals()

  $('.clear-distribution').on 'click', ->
    tr = $(this).closest('tr')
    tr.find('input').val('')
    tr.find('select').val('')
    tr.find('.pc input').val('')
    tr.find('.pc a').text('none')
    tr.find('.pc .destroy-input').val('1')
    tr.hide()