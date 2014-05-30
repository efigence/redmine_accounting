$(function() {
  $('.selectize').selectize({
    sortField: 'text'
  });
  $('.selectize-with-btn').selectize({
    plugins: ['remove_button']
  });
  $(".list th").each(function(){
    var length = $(this).text().trim().length
    if(!length) {
      $(this).remove();
    };
  })
});
