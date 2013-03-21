class CreateJournalAndGroupJoinTable < ActiveRecord::Migration
  def self.up
    create_table :groups_journals, :id => false do |t|
      t.integer :journal_id
      t.integer :group_id
    end
  end

  def self.down
    drop_table :journals_groups
  end
end

