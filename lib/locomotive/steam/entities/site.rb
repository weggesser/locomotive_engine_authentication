require_dependency File.join Gem.loaded_specs['locomotivecms_steam'].full_gem_path, 'lib/locomotive/steam/entities/site'

class Locomotive::Steam::Site
  
  attr_writer :protected_login_page_handle  
  def protected_login_page_handle
    self[:protected_login_page_handle] || "index"
  end
  
  attr_writer :  
  def protected_default_page_handle
    self[:protected_default_page_handle] || "index"
  end
  
  attr_writer :protected_register_page_handle  
  def protected_register_page_handle
    self[:protected_register_page_handle] || "index"
  end
  
  attr_writer :protected_register_page_handle 
  def protected_doccheck_page_handle
    self[:protected_doccheck_page_handle] || "index"
  end
  
  attr_writer :reset_password_page_handle
  def reset_password_page_handle
    self[:reset_password_page_handle] || "index"
  end
  
  attr_writer :request_reset_password_page_handle
  def request_reset_password_page_handle
    self[:request_reset_password_page_handle] || "index"
  end
  
  
end
