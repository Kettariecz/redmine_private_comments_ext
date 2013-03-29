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
        project = journal.issue.project
        return false unless self.allowed_to?(:view_issues, journal.project) #Нет доступа к задачам - нет доступа к комментариям. Все просто.
        # return true unless (journal.private_notes?) #Публичные комментарии доступны всем.
# 
        # #Входит ли пользователь хотя бы в одну из групп, для которых доступен этот коммент?
        # journal.groups.where(:id => self.groups.pluck(:id)).exists?
        if journal.private_notes? then
          return false unless (self.allowed_to?(:view_private_notes, project) ) #Нет доступа к приватным - не видишь его.
        end
        self.is_member_one_of_the_groups?(journal.groups) ? true : false #Комментарий доступен, если пользователь входит в одну из групп, которым доступен комментарий
    end

    #возвращает группы, которым по-умолчанию будут доступны комментарии пользователя
    #Т.е. группы, в которые входит пользователь, и группы, которые могут читать комментарии этих групп 
    def groups_allowed_to_read
      return [] unless self.groups.any?
      allowed_readers = []
      allowed_readers += self.groups #группы, в которые входит пользователь
      self.groups.each{|group| allowed_readers += group.allowed_groups_readers} #группы, которые могут читать комментарии групп, в которые входит пользователь
      allowed_readers
    end
    
  end

end