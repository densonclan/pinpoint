jQuery ->
  $('form.no-lock input, form.no-lock textarea, form.no-lock select').attr('disabled', true)

  prepend_alert_message = (text) ->
    $('form.no-lock').prepend "<div class='alert alert-warn not-locked-alert'>#{text}</div>"

  if $('form.no-lock').length == 1
    if $('.record-lock').hasClass('locked')
      prepend_alert_message "You cannot make changes because this record is locked by #{$('.record-lock').data('locked-by')}"
    else
      prepend_alert_message "You cannot make changes until you obtain the lock by clicking the lock icon on the right"

  set_beforeunload_handler = ->
    window.onbeforeunload = ->
      'You have the lock on this object, this will prevent anyone else making  changes to this object'

  unset_beforeunload_handler = ->
    window.onbeforeunload = null

  if $('form.has-lock').length > 0
    set_beforeunload_handler()

  $('input.save-button').on 'click', ->
    unset_beforeunload_handler()
    true

  $('a.delete-button').on 'click', ->
    unset_beforeunload_handler()
    if confirm("Are you sure you want to delete this?")
      true
    else
      set_beforeunload_handler()
      false  

  lock_granted = (id) ->
    $('form.no-lock input, form.no-lock textarea, form.no-lock select').attr('disabled', false)
    $('form.no-lock').addClass('has-lock').removeClass('no-lock')
    $('form .record-lock').attr('title', 'Record locked by you. Click to release lock')
    $('form .record-lock').attr('href', "/record_locks/#{id}")
    set_beforeunload_handler()

  lock_rejected = ->
    alert('Unable to obtain record lock. Someone else may have already reqested the lock - reload to find out')

  lock_released = (id, type) ->
    $('form.has-lock input, form.has-lock textarea, form.has-lock select').attr('disabled', true)
    $('form.has-lock').addClass('no-lock').removeClass('has-lock')
    $('form .record-lock').attr('title', 'Click to lock record')
    $('form .record-lock').attr('href', "/record_locks?record_lock[record_id]=#{id}&record_lock[record_type]=#{type}")
    unset_beforeunload_handler()

  lock_release_failed = ->
    alert('Unable to release the record lock. Please refresh')

  request_lock = (a) ->
    $.ajax {
      url: a.attr('href')
      type: 'POST'
      dataType: 'JSON'
      success: (data) ->
        lock_granted(data.id)
      error: ->
        lock_rejected()
    }

  release_lock = (a) ->
    $.ajax {
      url: a.attr('href')
      type: 'DELETE'
      dataType: 'JSON'
      success: (data) ->
        lock_released(data.record_id, data.record_type)
      error: ->
        lock_release_failed()
    }

  $('a.record-lock').on 'click', ->
    if $(this).closest('form').hasClass('no-lock') then request_lock($(this)) else release_lock($(this))
    false