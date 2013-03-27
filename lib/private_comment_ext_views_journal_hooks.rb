module PrivateCommentsExt

  class PrivateCommentsExtViewJournalHooks < Redmine::Hook::ViewListener     
    
    #вставляем форму с выбором групп, которым будет доступен комментарий, в форму обновления задачи
    def view_issues_edit_notes_bottom(context={ })
      issue = context[:issue]
      project = issue.project
      
      context[:controller].send(:render_to_string, {:partial => "issues/private_new_notes_bottom", 
          :locals => {:issue => issue, :aDefGroups => User.current.groups_allowed_to_read, 
                      :bCanChangeGroups => User.current.allowed_to?(:manage_group_access_to_notes, project)} })
          
    end 

    #вставляем форму с выбором групп, которым будет доступен комментарий, в форму пакетного обновления нескольких задач
    def view_issues_bulk_edit_details_bottom(context={ })
      issues = context[:issues]
      
      context[:controller].send(:render_to_string, {:partial => "issues/private_new_notes_bottom", 
          :locals => {:aDefGroups => User.current.groups_allowed_to_read, 
                      :bCanChangeGroups => false}}) #при пакетном обновлении запрещено изменять набор групп 
                      
          
    end       
      
    #прерывание перед сохранением нового комментария (редактирование задачи)
    def controller_issues_edit_before_save(context={ })
      params = context[:params]
      return if params[:group_ids].blank?

      journal = context[:journal]
      allowed_groups = Group.find(params[:group_ids])
      #список групп сохраняем только для приватных комментариев
      # if journal.private_notes?
         # journal.groups = allowed_groups       
      # end
      journal.groups = allowed_groups #не зависимо от приватности комментария
    end

    #прерывание перед сохранением пакетного редактирования задач
    def controller_issues_bulk_edit_before_save(context={ })
      params = context[:params]
      issue = context[:issue]
      journal = issue.init_journal(User.current)
      allowed_groups = User.current.groups_allowed_to_read
      #список групп сохраняем только для приватных комментариев
      # if journal.private_notes?
         # journal.groups = allowed_groups       
      # end
      journal.groups = allowed_groups #не зависимо от приватности комментария
    end
        
    #добавляем список групп в форму редактирования комментария
    def view_journals_notes_form_after_notes(context={ })
      journal = context[:journal]
      project = journal.issue.project
      context[:controller].send(:render_to_string, {:partial => "issues/private_new_notes_bottom", 
          :locals => {:aDefGroups => journal.groups, 
                      :bCanChangeGroups => User.current.allowed_to?(:manage_group_access_to_notes, project)} })  
    end    
        
        
    #прерывание перед сохранением измененного комментария    
    def controller_journals_edit_post(context={ })
      params = context[:params]
      return if params[:group_ids].blank?

      journal = context[:journal]
      allowed_groups = Group.find(params[:group_ids])
      #список групп сохраняем только для приватных комментариев
      # if journal.private_notes?
         # journal.groups = allowed_groups       
      # end
      journal.groups = allowed_groups #не зависимо от приватности комментария
    end    
        
  end   

end
