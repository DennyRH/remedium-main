class CreateAccessAlloweds < ActiveRecord::Migration[7.0]
  def change
    create_table :access_alloweds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true

      t.timestamps
    end
  end
end
