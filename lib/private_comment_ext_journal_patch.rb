module PrivateCommentExtJournalPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке

      has_and_belongs_to_many :groups, :join_table => "groups_journals" 
      
                                               
      scope :visible, lambda {|*args|
        user = args.shift || User.current
    
        includes(:issue => :project).
          where(Issue.visible_condition(user, *args)).
          # where("(#{Journal.table_name}.private_notes = ? OR "+ 
                # "(#{Journal.table_name}.id in (select journal_id from groups_journals where "+
                # "group_id in (#{user.groups.any? ? user.groups.pluck(:id) : 0}))))", false)
          where("((#{Journal.table_name}.private_notes = ? OR (#{Project.allowed_to_condition(user, :view_private_notes, *args)})) AND " + 
                "(#{Journal.table_name}.id in (select journal_id from groups_journals where "+
                "group_id in (#{user.groups.any? ? user.groups.pluck(:id).join(',') : 0}))) OR (#{Journal.table_name}.notes is null))", false)

      }
      
      alias_method_chain :recipients, :private_comments
      alias_method_chain :split_private_notes, :private_comments #необходимо разделять все комментарии, а не только приватные
    end

  end


  module ClassMethods
  end
      
      
  module InstanceMethods


  # Модифицированный метод из 2.2.х.
    def recipients_with_private_comments
      notified = journalized.notified_users
      #if private_notes?
        #notified = notified.select {|user| user.is_member_one_of_the_groups?(self.groups)}
        notified = notified.select {|user| user.is_visible_comment?(self)}
      #end
      notified.map(&:mail)
    end
  
    private
   
   #необходимо разделять все комментарии, а не только приватные
    def split_private_notes_with_private_comments
      if notes.present?
        if details.any?
          # Split the journal (notes/changes) so we don't have half-private journals
          journal = Journal.new(:journalized => journalized, :user => user, :notes => nil, :private_notes => false)
          journal.details = details
          journal.save
          self.details = []
          self.created_on = journal.created_on
        end
      else
        # Blank notes should not be private
        self.private_notes = false
      end
      true      
    end
    
  end

end