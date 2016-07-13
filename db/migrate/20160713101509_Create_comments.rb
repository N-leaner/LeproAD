class CreateComments < ActiveRecord::Migration
  def change
  	create_table :comments do |t|
  		t.integer :user
  		t.integer :post
		t.text :comment

  		t.timestamps
  	end
  end
end
