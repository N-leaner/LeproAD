class CreateUsers < ActiveRecord::Migration
  def change
  	create_table :users do |t|
      t.string :name
      t.string :password     
      t.timestamps 
    end
 
    create_table :posts do |t|
      t.belongs_to :user
      t.text :post
      t.timestamps
    end

    create_table :comments do |t|
    	t.belongs_to :post
    	t.belongs_to :user  		
		t.text :comment
  		t.timestamps
  	end

    User.create :name => 'Admin', :password => '1234'
  end
end
