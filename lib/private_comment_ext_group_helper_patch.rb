require_dependency 'groups_helper'

module PrivateCommentExtGroupHelperPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке

      alias_method_chain :group_settings_tabs, :private_comments
    end

  end
      
  module InstanceMethods
    
    #добавляем вкладку со списком групп, которым будут доступны комментарии, в настройки группы.    
    def group_settings_tabs_with_private_comments
      tab = group_settings_tabs_without_private_comments
      #tab << {:name => 'groups_reader', :partial => 'groups/groups_reader', :label => :label_groups_reader}
      tab << {:name => 'groups_allowed_author', :partial => 'groups/groups_allowed_author', :label => :label_groups_allowed_author}
    end

  end

end