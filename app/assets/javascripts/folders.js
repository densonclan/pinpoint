$(function(){
  $(".select-users").select2();
  $('.share-folder').click(function(e){
    e.preventDefault();
    var element = $(this);
    $('#shareModal .modal-title').html('Share folder : ' + element.data('name'));
    $.get(element.data('share-url'), function(data){
      $('#shareModal').modal();
      var selectedUsers = [];
      if(data) {
        selectedUsers = data.map(function(u){return u.user_id;});
      }
      $("#shareModal form").attr("action", element.data('share-url'));
      $(".select-users").select2('val', selectedUsers);
    })
  });
  $('#shareModal .save-button').click(function(e){
    e.preventDefault();
    $.post($("#shareModal form").attr("action"), {users: $(".select-users").select2('val')}, function(){
      $('#shareModal').modal('hide');
    })
  });
});