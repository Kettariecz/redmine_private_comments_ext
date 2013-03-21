module PrivateCommentExtMailerPatch

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

  # Копия из версии 2.2.х
  # Builds a Mail::Message object used to email recipients of the edited issue.
  #
  # Example:
  #   issue_edit(journal) => Mail::Message object
  #   Mailer.issue_edit(journal).deliver => sends an email to issue recipients
  # def issue_edit(journal)
    # issue = journal.journalized.reload
    # redmine_headers 'Project' => issue.project.identifier,
                    # 'Issue-Id' => issue.id,
                    # 'Issue-Author' => issue.author.login
    # redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    # message_id journal
    # references issue
    # @author = journal.user
    # recipients = journal.recipients
    # # Watchers in cc
    # cc = journal.watcher_recipients - recipients
    # s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    # s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
    # s << issue.subject
    # @issue = issue
    # @journal = journal
    # @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")
    # mail :to => recipients,
      # :cc => cc,
      # :subject => s
  # end

  end

end