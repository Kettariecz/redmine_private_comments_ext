require_dependency 'journals_controller'

module PrivateCommentExtJournalsControllerPatch

include Redmine::SafeAttributes

  def self.included(base) # :nodoc:

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке

    end

  end
      
  module InstanceMethods

    
    #изменяет набор групп, которым разрешен просмотр приватного комментария
    def change_allowed_readers
      @journal = Journal.find(params[:id])
      group_ids = (params[:group_ids]||params[:group_id])
      group_ids.blank? ? @journal.groups.clear : (@journal.groups = Group.find(params[:group_ids]||params[:group_id]))    
            
    end


  end

end