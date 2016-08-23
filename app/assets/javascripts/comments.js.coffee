jQuery ->
  $('#comment_save_as_task').on 'click', ->
    if $(this).prop('checked')
      $('.comment_assignee_id, .comment_due_date, .comment_department_id').show()
    else
      $('.comment_assignee_id, .comment_due_date, .comment_department_id').hide()