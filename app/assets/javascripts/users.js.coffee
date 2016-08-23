jQuery ->

  isInternalUser = -> $('#user_user_type').val() == '1' || $('#user_user_type').val() == '2'

  hideOrShowClient = ->
    if isInternalUser()
      console.log('internal')
      $('#user_client_id').val('')
      $('.user_client_id').hide()
    else
      $('.user_client_id').show()    

  $('form.edit_user #user_user_type').on 'change', ->
    hideOrShowClient()

  if $('form.edit_user').length == 1
    console.log('edit user')
    hideOrShowClient()