class CreateOrderConfigurations < ActiveRecord::Migration
  def change
    create_table :order_configurations do |t|
      t.string :name
      t.text :url
      t.string :listing_id
      t.decimal :threshold, precision: 30, scale: 15
      t.integer :times_called
      t.references :user, index: true
      t.references :device, index: true

      t.timestamps null: false
    end
    add_foreign_key :order_configurations, :users
    add_foreign_key :order_configurations, :devices
  end
end
