class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def render_404(message = "Not Found")
    raise ActionController::RoutingError.new(message)
  end
end
