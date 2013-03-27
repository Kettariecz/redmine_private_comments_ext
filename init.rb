require 'redmine'

Rails.configuration.to_prepare do
  Journal.send(:include, PrivateCommentExtJournalPatch) unless Journal.included_modules.include?(PrivateCommentExtJournalPatch)
  JournalsController.send(:include, PrivateCommentExtJournalsControllerPatch) unless Issue.included_modules.include?(PrivateCommentExtJournalsControllerPatch)

  Group.send(:include, PrivateCommentExtGroupPatch) unless Group.included_modules.include?(PrivateCommentExtGroupPatch)
  GroupsHelper.send(:include, PrivateCommentExtGroupHelperPatch) unless GroupsHelper.included_modules.include?(PrivateCommentExtGroupHelperPatch)
  GroupsController.send(:include, PrivateCommentExtGroupsControllerPatch) unless GroupsController.included_modules.include?(PrivateCommentExtGroupsControllerPatch)  

  Issue.send(:include, PrivateCommentExtIssuePatch) unless Issue.included_modules.include?(PrivateCommentExtIssuePatch)
  IssuesController.send(:include, PrivateCommentExtIssuesControllerPatch) unless IssuesController.included_modules.include?(PrivateCommentExtIssuesControllerPatch)

  Mailer.send(:include, PrivateCommentExtMailerPatch) unless Mailer.included_modules.include?(PrivateCommentExtMailerPatch)

  User.send(:include, PrivateCommentExtUserPatch) unless User.included_modules.include?(PrivateCommentExtUserPatch)
end
   
require_dependency 'private_comment_ext_views_journal_hooks'
   
Redmine::Plugin.register :private_comments_ext do
  name 'Private Comments Ext plugin'
  author 'Alexander Kulemin'
  description 'Private Comments by users groups.'
  version '0.0.1'

  #Global permissions
  project_module :issue_tracking do
    permission :manage_group_access_to_notes, {}, :require => :member
  end

 

end
