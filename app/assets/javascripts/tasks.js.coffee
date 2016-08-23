jQuery ->
  $('form.taskable #agent-id').change ->
    if $(this).val() == ''
      $('form.taskable #department-id option:first').text('Select a department')
      $('form.taskable #department-id').attr('disabled', false)
    else
      $('form.taskable #department-id').attr('disabled', true)
      $('form.taskable #department-id option:first').text('- assigned to a person -')

  $('form.taskable #department-id').change ->
    if $(this).val() == ''
      $('form.taskable #agent-id option:first').text('Select a person')
      $('form.taskable #agent-id').attr('disabled', false)
    else
      $('form.taskable #agent-id option:first').text('- assigned to a department -')
      $('form.taskable #agent-id').attr('disabled', true)
      $('form.taskable #agent-id').val('')