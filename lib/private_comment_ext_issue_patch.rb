module PrivateCommentExtIssuePatch

include Redmine::SafeAttributes

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке

      has_many :visible_journals,
        :class_name => 'Journal',
        :as => :journalized,
        :conditions => Proc.new { 
          ["(#{Journal.table_name}.private_notes = ? /*ccc*/ OR "+
           "(#{Journal.table_name}.id in (select journal_id from groups_journals where "+
           "group_id in (#{User.current.groups.pluck(:id)}))))", false]
        },
        :readonly => true      

    end

  end
      
  module ClassMethods

  end
      
  module InstanceMethods

    # Returns the users that should be notified
    def notified_users
        notified = []
        
        # Author and assignee are always notified unless they have been
        # locked or don't want to be notified
        notified << author if author
        
        if assigned_to
          notified += (assigned_to.is_a?(Group) ? assigned_to.users : [assigned_to])
        end
        
        if assigned_to_was
          notified += (assigned_to_was.is_a?(Group) ? assigned_to_was.users : [assigned_to_was])
        end
        
        notified = notified.select {|u| u.active? && u.notify_about?(self)}
        notified += project.notified_users
        notified.uniq!

        # Remove users that can not view the issue
        notified.reject! {|user| !visible?(user)}
        notified
    end

    # Returns the email addresses that should be notified
    def recipients
        notified_users.collect(&:mail)
    end

  end

end