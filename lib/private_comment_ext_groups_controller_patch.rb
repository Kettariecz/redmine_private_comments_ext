require_dependency 'groups_controller'

module PrivateCommentExtGroupsControllerPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке

    end

  end
      
  module InstanceMethods
    
    #Запрещает группе читать приватные комментарии указанных групп (authors)    
    def disable_to_read_groups
      @authors = Group.find(params[:author_group_id])
      @group.allowed_groups_authors.delete(@authors)
    end

    #Разрешает группе читать приватные комментарии указанных групп (authors)    
    def enable_to_read_groups
      @authors = Group.find(params[:author_group_ids]||params[:author_group_id])
      @group.allowed_groups_authors << @authors
    end


  end

end