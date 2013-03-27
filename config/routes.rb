# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'groups/enable_to_read_groups/:id', :controller => 'groups', :action => 'enable_to_read_groups', :id => /\d+/, :via => :post
match 'groups/disable_to_read_groups/:id', :controller => 'groups', :action => 'disable_to_read_groups', :id => /\d+/,  :via => :post
match 'groups/enable_reader_group/:id', :controller => 'groups', :action => 'enable_reader_group', :id => /\d+/, :via => :post
match 'groups/disable_reader_group/:id', :controller => 'groups', :action => 'disable_reader_group', :id => /\d+/,  :via => :post


match 'journals/change_allowed_readers/:id', :controller => 'journals', :action => 'change_allowed_readers', :id => /\d+/,  :via => [:post, :put]