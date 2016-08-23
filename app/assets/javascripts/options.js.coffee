jQuery ->
  $('form.option-form .value-title a').on 'click', ->
    $('.value-title a').removeClass('selected')
    $(this).addClass('selected')
    $('.value').removeClass('selected')
    $(".value-#{$(this).data('id')}").addClass('selected')
    false