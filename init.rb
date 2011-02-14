require 'redmine'

Redmine::Plugin.register :redmine_activity_module do
  name 'Redmine Activity Module Plugin'
  author 'Gregor Schmidt'
  description 'This Plugin makes activity a module, such that it can be activated and deactivated on a per-project setting.'
  version '0.0.1'
  url 'http://github.com/finnlabs/redmine_activity_module'
  author_url 'http://www.finn.de/'
end

require 'dispatcher'
Dispatcher.to_prepare :redmine_activity_module do
  require_dependency 'activities_controller'
  require_dependency 'application_controller'
  require_dependency 'redmine/access_control'

  ActivitiesController.class_eval do
    def verify_activities_module_activated
      render_403 unless @project && @project.enabled_module_names.include?("activity")
    end

    before_filter :verify_activities_module_activated
    private :verify_activities_module_activated
  end

  ApplicationController.master_helper_module.class_eval do
    def allowed_node?(node, user, project)
      if node.name == :activity
        project.enabled_module_names.include? "activity"
      else
        super
      end
    end
  end

  Redmine::AccessControl.metaclass.class_eval do
    def available_project_modules_with_activity
      @available_project_modules_with_activity ||= available_project_modules_without_activity.unshift("activity")
    end
    alias_method_chain :available_project_modules, :activity unless instance_methods.include? "available_project_modules_without_activity"
  end
end
