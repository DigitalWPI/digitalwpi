
$(document).on("click", ".copy_bookmark_url", function() {
  var text_to_copy = document.getElementById("shareable-url").innerHTML;

  if (!navigator.clipboard) {
    // use old commandExec() way
    var html_alert = "<div class=\"alert alert-warning alert-dismissible fade show\" role=\"alert\">\n" +
        "  <strongCopied!</strong> \n" +
        "  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\">\n" +
        "    <span aria-hidden=\"true\">&times;</span>\n" +
        "  </button>\n" +
        "</div>"
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val(text_to_copy).select();
    document.execCommand("copy");
    // Remove the temporary input
    $temp.remove();
    $('#bookmark-url-copy-msg').html = html_alert;
  } else {
    navigator.clipboard.writeText(text_to_copy).then(
      function(){
        // success
        $('#bookmark-url-copy-msg').html = html_alert;
    }).catch(
      function() {
        // error
        $('#bookmark-url-copy-msg').html = html_alert;
    });
  }
});

// Close modal on cancel button click
$(document).on("click", "#select-bookmark-category-modal-cancel", function() {
  $('#select-bookmark-category-modal').hide();
});

// Close modal on cancel button click
$(document).on("click", "#bookmark-category-modal-cancel", function() {
  $('#bookmark-category-modal').hide();
});

// Select all checkboxes when "Select All" is checked
$(document).on("change", "#select-all-bookmark-documents", function() {
  $('.bookmark-document').prop('checked', $(this).prop('checked'));
  button_identifier = $("#bookmark_category_id").val() ? "#remove-from-category" : "#add-to-category"
  if ($(this).prop('checked')) {
    $(button_identifier).show();
  } else {
    $(button_identifier).hide();
  }
});

// Show/hide add to category button based on checkbox selection
$(document).on("change",".bookmark-document", function() {
  button_identifier = $("#bookmark_category_id").val() ? "#remove-from-category" : "#add-to-category"
  if ($('.bookmark-document:checked').length > 0) {
    $(button_identifier).show();
  } else {
    $(button_identifier).hide();
  }
});

// Close modal on cancel button click
$(document).on("click", "#remove-from-category", function() {
  var selected_category = $("#bookmark_category_id").val();
  var selected_bookmark_document_ids = [];
  $('.bookmark-document:checked').each(function() {
    selected_bookmark_document_ids.push($(this).val());
  }); 

  // Perform AJAX request to update categories
  $.ajax({
    url: 'bookmarks/remove_category_from_bookmark',
    type: 'post',
    data: {
      bookmark_category_id: selected_category,
      bookmark_document_ids: selected_bookmark_document_ids
    },
    success: function(response) {
      window.location.href = window.location.href;
    },
    error: function(xhr, status, error) {
      window.location.href = window.location.href;
      alert(xhr.responseJSON.errors)
    }
  });
});

// Submit modal form
$(document).on("click", "#select-bookmark-category-modal-Submit", function() {
  var selected_category = $('#bookmark-category-select').val();
  var selected_bookmark_document_ids = [];
  $('.bookmark-document:checked').each(function() {
    selected_bookmark_document_ids.push($(this).val());
  }); 

  // Perform AJAX request to update categories
  $.ajax({
    url: 'bookmarks/update_category_to_bookmark',
    type: 'POST',
    data: {
      bookmark_category_id: selected_category,
      bookmark_document_ids: selected_bookmark_document_ids
    },
    success: function(response) {
      // Handle success
      $('#select-bookmark-category-modal').hide();
      // Redirect to the same page
      window.location.href = window.location.href;
    },
    error: function(xhr, status, error) {
      $(".bookmark-category-error").html("<div class='alert alert-danger'>" + xhr.responseJSON.errors + "</div>")
    }
  });
});
