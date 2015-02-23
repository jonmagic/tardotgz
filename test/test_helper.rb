$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "tardotgz"
require "minitest/autorun"
require "pathname"

def path_helper(path_relative_to_project_root)
  project_root = File.expand_path("../", File.dirname(__FILE__))
  Pathname(project_root).join(path_relative_to_project_root)
end
