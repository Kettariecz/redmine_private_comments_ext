class CreateGroupAuthorAndGroupReaderJoinTable < ActiveRecord::Migration
  def self.up
    create_table :group_reader_author, :id => false do |t|
      t.integer :author_groups_id
      t.integer :reader_groups_id
    end
  end

  def self.down
    drop_table :group_reader_author
  end
end

