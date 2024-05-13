
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
  if ($(this).prop('checked')) {
    $('#add-to-category').show();
  } else {
    $('#add-to-category').hide();
  }
});

// Show/hide add to category button based on checkbox selection
$(document).on("change",".bookmark-document", function() {
  if ($('.bookmark-document:checked').length > 0) {
    $('#add-to-category').show();
  } else {
    $('#add-to-category').hide();
  }
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
