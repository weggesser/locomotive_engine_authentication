#require_dependency File.join Gem.loaded_specs['locomotivecms_steam'].full_gem_path, 'lib/locomotive/steam/entities/page'

class Locomotive::Steam::Page
  
  def initialize(attributes)
      super({
        handle:             nil,
        listed:             false,
        published:          true,
        templatized:        false,
        cache_enabled:      true,
        fullpath:           {},
        protected:          false,
        response_type:      nil,
        content_type:       nil,
        target_klass_name:  nil,
        position:           99,
        raw_template:       nil,
        source:             nil,
        editable_elements:  {},
        redirect:           nil,
        redirect_url:       {},
        redirect_type:      nil,
        parent_id:          nil,
        parent_ids:         nil,
        updated_at:         Time.zone.now
      }.merge(attributes))
    end
  
  attr_writer :protected  
  def protected
    self[:protected] || false
  end
  
  def is_accessible_by? user
    if ::Locomotive::Steam.configuration.mode != :test
      ( self.protected and !user.nil? user.site_id == self.site_id ) or !self.protected
    else
      ( self.protected and !user.nil? ) or !self.protected
    end
  end

end
