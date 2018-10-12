class AddAuthors < ActiveRecord::Migration[5.0]
  def change
    create_table :authors do |t|
      t.datetime :published_at
    end

    add_column :articles, :author_id, :string
  end
end
