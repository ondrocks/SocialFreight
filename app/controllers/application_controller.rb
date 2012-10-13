class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_patron, :current_operation, :current_tab

  def follow_object(object)
    current_user.follow(object)
  end

  def set_tab(tab_id)
    session[:current_tab] = tab_id
  end
  
  protected
  def current_tab
    current_tab = "homenavigator"
    current_tab = session[:current_tab] if session[:current_tab]
    current_tab
  end

  protected
  def current_patron
    @current_patron ||= Patron.find(session[:patron_id]) if session[:patron_id]
  end

  protected
  def current_operation
    @current_operation = session[:current_operation] if session[:current_operation]
  end

  def require_patron
    if !patron_user?
      session[:return_to_url] = request.url if Config.save_return_to_url
      self.send(Config.not_authenticated_action)
    end
  end

  protected
  def not_authenticated
    redirect_to root_path, :alert => "Please login first."
  end

  def patron_user?
    !!current_patron
  end

  layout proc { |controller|
    if controller.params[:nolayout]
      nil
    else
      current_patron ? "application" : "guest"
    end
  }

  def set_locale
    #locale = logged_in? ? current_user.locale : (params[:locale])
    if logged_in?
      locale = current_user.language
    end
    if not locale.present?
      locale = cookies[:socialfreight_locale]
    end
    if not locale.present?
      locale = Timeout::timeout(5) { Net::HTTP.get_response(URI.parse('http://api.hostip.info/country.php?ip=' + request.remote_ip )).body } rescue I18n.default_locale
      cookies[:socialfreight_locale] = locale
    end
    I18n.locale = (locale.present? && I18n.available_locales.include?(locale.to_sym)) ? locale : I18n.default_locale
  end
  
  def set_time_zone
    if logged_in?
      Time.use_zone(current_user.time_zone) do
        yield
      end
    else
      yield
    end
  end
    
end
