$(document).on('click','.more-or-less-button', function(e) {
  if ($(this).text() == 'more >>'){
    $(this).text('less <<')
  }
  else{
    $(this).text('more >>')
  }
});