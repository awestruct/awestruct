require 'yaml'

module Awestruct
  def self.yaml_load(str)
    return YAML.load(str) unless YAML.method('load').parameters.any? {|k,v| v == :permitted_classes}
    YAML.load(str, permitted_classes: [Date, Symbol])  
  end

  def self.yaml_load_file(str)
    return YAML.load_file(str) unless YAML.method('load').parameters.any? {|k,v| v == :permitted_classes}
    YAML.load_file(str, permitted_classes: [Date, Symbol])
  end

end
