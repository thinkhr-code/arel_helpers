class AddArticleModel < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.references :author
      t.datetime :published_at
    end
  end
end
