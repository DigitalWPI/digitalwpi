$(document).on("click", ".copy_bookmark_url", function() {
  var $button = $(this);
  var text_to_copy = $("#shareable-url").text().trim();
  var original_text = "Copy Url";

  function copied() {
    $button.text("Copied");
    $button.removeClass("btn-primary").addClass("btn-secondary");
    $button.addClass("disabled").css("pointer-events", "none");

    setTimeout(function() {
      $button.text(original_text);
      $button.removeClass("btn-secondary").addClass("btn-primary");
      $button.removeClass("disabled").css("pointer-events", "");
    }, 1500);
  }

  if (!navigator.clipboard) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val(text_to_copy).select();
    document.execCommand("copy");
    $temp.remove();
    copied();
  } else {
    navigator.clipboard.writeText(text_to_copy).then(function() {
      copied();
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
