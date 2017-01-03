class AddXueweikeAttribute < ActiveRecord::Migration
  def change
      add_column:grades, :xueweike, :boolean, default:false
  end
end
