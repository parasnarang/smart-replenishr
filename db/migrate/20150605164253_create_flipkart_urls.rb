class CreateFlipkartUrls < ActiveRecord::Migration
  def change
    create_table :flipkart_urls do |t|
      t.string :name
      t.string :url

      t.timestamps null: false
    end
  end
end
