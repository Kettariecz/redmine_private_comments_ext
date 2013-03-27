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

    #Исключает группу из списка, кому доступны комментарии текущей группы    
    def disable_reader_group
      @reader = Group.find(params[:reader_group_id])
      @group.allowed_groups_readers.delete(@reader)
    end

    #Включает группу в список, кому доступны комментарии текущей группы    
    def enable_reader_group
      @readers = Group.find(params[:reader_group_ids]||params[:reader_group_id])
      @group.allowed_groups_readers << @readers
    end


  end

end