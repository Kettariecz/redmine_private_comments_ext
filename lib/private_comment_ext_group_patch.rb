module PrivateCommentExtGroupPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # послать unloadable чтобы не перегружать при разработке
      has_and_belongs_to_many :journals, :join_table => "groups_journals" 
      
      #группы, которым будут доступны приватные комментарии выбранной группы.
      has_and_belongs_to_many :allowed_groups_readers, #allowed_to_read_groups 
          :class_name => 'Group', :join_table => "group_reader_author", 
          :foreign_key => "author_groups_id",
          :association_foreign_key => "reader_groups_id"


      #группы, приватные комментарии которых доступны данной группе.     
      has_and_belongs_to_many :allowed_groups_authors, #visible_comments_author_groups 
          :class_name => 'Group', :join_table => "group_reader_author", 
          :foreign_key => "reader_groups_id",
          :association_foreign_key => "author_groups_id"

    end

  end
      
  module ClassMethods
    
  end
      
  module InstanceMethods

    def not_in_available_authors
      self.allowed_groups_authors.any? ? 
          available = Group.where("id not in (?)", self.allowed_groups_authors) : available = Group.where("1=1")
      available
    end
    
    def not_in_available_readers
      self.allowed_groups_readers.any? ? 
          available = Group.where("id not in (?)", self.allowed_groups_readers) : available = Group.where("1=1")
      available
    end
    
  end

end