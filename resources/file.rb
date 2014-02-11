actions :enable, :disable
default_action :enable

attribute :path, :name_attribute => true, :kind_of => String
attribute :size, :kind_of => String, :regex => %r{\d+[GgMm]?[Bb]?}

