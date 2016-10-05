require_dependency File.join Gem.loaded_specs['locomotivecms_steam'].full_gem_path, 'lib/locomotive/steam/entities/site'

class Locomotive::Steam::Site
  
  attr_writer :protected_login_page_handle  
  def protected
    self[:protected_login_page_handle] || "index"
  end
  
  attr_writer :protected_default_page_handle  
  def protected
    self[:protected_default_page_handle] || "index"
  end
  
  attr_writer :protected_register_page_handle  
  def protected
    self[:protected_register_page_handle] || "index"
  end
  
end
