module PrivateCommentsExt

  class PrivateCommentsExtViewJournalHooks < Redmine::Hook::ViewListener     
    
    #вставляем форму с выбором групп, которым будет доступен комментарий, в форму обновления задачи
    def view_issues_edit_notes_bottom(context={ })
      issue = context[:issue]
      
      context[:controller].send(:render_to_string, {:partial => "issues/private_new_notes_bottom", 
          :locals => {:issue => issue, :aDefGroups => User.current.groups} })       
    end 
      
      
    #прерывание перед сохранением нового комментария (редактирование задачи)
    def controller_issues_edit_before_save(context={ })
      params = context[:params]
      return if params[:group_ids].blank?

      journal = context[:journal]
      allowed_groups = Group.find(params[:group_ids])
      #список групп сохраняем только для приватных комментариев
      if journal.private_notes?
         journal.groups = allowed_groups       
      end
      
    end
        
    #добавляем список групп в форму редактирования комментария
    def view_journals_notes_form_after_notes(context={ })
      journal = context[:journal]
      context[:controller].send(:render_to_string, {:partial => "issues/private_new_notes_bottom", 
          :locals => {:aDefGroups => journal.groups} })  
    end    
        
        
    #прерывание перед сохранением измененного комментария    
    def controller_journals_edit_post(context={ })
      params = context[:params]
      return if params[:group_ids].blank?

      journal = context[:journal]
      allowed_groups = Group.find(params[:group_ids])
      #список групп сохраняем только для приватных комментариев
      if journal.private_notes?
         journal.groups = allowed_groups       
      end
    end    
        
  end   

end
