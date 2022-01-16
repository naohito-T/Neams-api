class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      # 主キーはidという名前で暗黙に追加されます。idはActive Recordモデルにおけるデフォルトの主キー
      # timestampsマクロは、created_atとupdated_atという2つのカラムを追加します
      t.timestamps
      t.string :name, null: false, comment: "ユーザの名前"
      t.string :email, null: false, comment: "ユーザのメールアドレス"
      t.string :password_digest, null: false, comment: ""
      t.boolean :activated, null: false, default: false "規約に同意"
      t.boolean :admin, null: false, default: false, comment: "管理者権限の可否"
    end
  end
end
