module PrivateCommentExtJournalPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке

      has_and_belongs_to_many :groups, :join_table => "groups_journals" 
      
      before_create :split_private_notes #приватными могут быть только комментарии, 
                                         #поэтому отделяем их от других изменений перед сохранением    
      #before_create :set_allowed_readers, :if => :private_notes? #устанавливаем, каким группам будет доступен комментарий 
                                                                 #(если он отмечен как приватный)
                                               
      scope :visible, lambda {|*args|
        user = args.shift || User.current
    
        includes(:issue => :project).
          where(Issue.visible_condition(user, *args)).
          where("(#{Journal.table_name}.private_notes = ? OR "+ 
                "(#{Journal.table_name}.id in (select journal_id from groups_journals where "+
                "group_id in (#{user.groups.any? ? user.groups.pluck(:id) : 0}))))", false)
      }
      
      alias_method_chain :css_classes, :private_comments
      alias_method_chain :recipients, :private_comments
    end

  end


  module ClassMethods
  end
      
      
  module InstanceMethods

#     Добавляет новый css-класс. В версии 2.2.х м.б. удалено, т.к. там этот метод есть в ядре.
    def css_classes_with_private_comments
      s = css_classes_without_private_comments
      s << ' private-notes' if private_notes?
      s
    end

  # Модифицированный метод из 2.2.х.
    def recipients_with_private_comments
      notified = journalized.notified_users
      if private_notes?
        notified = notified.select {|user| user.is_member_one_of_the_groups?(self.groups)}
      end
      notified.map(&:mail)
    end
  
    private
    #устанавливаем, каким группам будет доступен комментарий
    #на основании групп, в которые входит автор.
    def set_allowed_readers
      self.groups = self.user.groups
    end
    
  end

end