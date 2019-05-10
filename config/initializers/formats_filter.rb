# frozen_string_literal: true
# Monkey patch as a work around for upgrading ActionView to 5.1.6.2 which
# breaks our app.
# Delete this file after we upgrade ActionView

ActionDispatch::Request.prepend(Module.new do
  def formats
    super().select do |format|
      format.symbol || format.ref == "*/*"
    end
  end
end)
