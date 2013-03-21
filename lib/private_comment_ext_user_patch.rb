module PrivateCommentExtUserPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке
    end

  end


  module ClassMethods
    
  end
      
      
  module InstanceMethods

    #проверяет, входит ли пользователь хотя бы в одну из групп из указанных
    def is_member_one_of_the_groups?(aGroups) 
       # return false if !self.groups.exists?
        aGroups = aGroups.is_a?(Group) ? aGroups.pluck(:id) : aGroups
        self.groups.where(:id => aGroups).exists?
    end

    #пользователь может видеть указанный комментарий? 
    def is_visible_comment?(journal) 
        journal = journal.is_a?(Journal) ? journal : Journal.first(journal.to_i)

        return false unless self.allowed_to?(:view_issues, journal.project) #Нет доступа к задачам - нет доступа к комментариям. Все просто.
        return true unless (journal.private_notes?) #Публичные комментарии доступны всем.

        #Входит ли пользователь хотя бы в одну из групп, для которых доступен этот коммент?
        journal.groups.where(:id => self.groups.pluck(:id)).exists?
    end

    
  end

end