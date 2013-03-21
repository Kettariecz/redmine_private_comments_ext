require_dependency 'issues_controller'

module PrivateCommentExtIssuesControllerPatch

include Redmine::SafeAttributes

  def self.included(base) # :nodoc:

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке
      
      alias_method_chain :show, :private_comment_ext
      alias_method_chain :update, :private_comment_ext
    end

  end
      
  module InstanceMethods
    
    #Изменено на основании версии 2.2.х.
    def show_with_private_comment_ext
      @journals = @issue.visible_journals.includes(:user, :details).reorder("#{Journal.table_name}.id ASC").all
      @journals.each_with_index {|j,i| j.indice = i+1}
      @journals.reverse! if User.current.wants_comments_in_reverse_order?
  
      @changesets = @issue.changesets.visible.all
      @changesets.reverse! if User.current.wants_comments_in_reverse_order?
  
      @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
      @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
      @priorities = IssuePriority.active
      @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
      respond_to do |format|
        format.html {
          retrieve_previous_and_next_issue_ids
          render :template => 'issues/show'
        }
        format.api
        format.atom { render :template => 'journals/index', :layout => false, :content_type => 'application/atom+xml' }
        format.pdf  {
          pdf = issue_to_pdf(@issue, :journals => @journals)
          send_data(pdf, :type => 'application/pdf', :filename => "#{@project.identifier}-#{@issue.id}.pdf")
        }
      end
    end

    #Изменено на основании версии 2.2.х.    
    def update_with_private_comment_ext
      return unless update_issue_from_params
      @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
      saved = false
      begin
        saved = @issue.save_issue_with_child_records(params, @time_entry)
        rescue ActiveRecord::StaleObjectError
          @conflict = true
          #patched: выбираем только те комментарии, которые могут быть доступны автору
          @conflict_journals = @issue.journals_after(params[:last_journal_id]).visible.all if params[:last_journal_id]
        end
     
        if saved
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?
    
          respond_to do |format|
            format.html { redirect_back_or_default({:action => 'show', :id => @issue}) }
          format.api  { render_api_ok }
        end
      else
        respond_to do |format|
          format.html { render :action => 'edit' }
          format.api  { render_validation_errors(@issue) }
        end
      end
    end

    
  end

end