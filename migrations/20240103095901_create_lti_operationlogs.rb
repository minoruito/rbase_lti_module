class CreateLtiOperationlogs < ActiveRecord::Migration[7.0]
  def change
    create_table :lti_operation_logs, comment: "LTI操作ログ" do |t|
      t.datetime :operated_at, comment: "操作日時"
      t.string :form_type, comment: "対象"
      t.integer :lms_user_id, comment: "LMSユーザID"
      t.string :user_id, comment: "ユーザID"
      t.string :user_name, comment: "ユーザ名"
      t.integer :inst_org_id, comment: "学部ID"
      t.string :institution, comment: "学部名"
      t.integer :dept_org_id, comment: "学科ID"
      t.string :department, comment: "学科名"
      t.integer :course_org_id, comment: "コースID"
      t.string :operation_log_target_type, comment: "対象"
      t.integer :input_category_id, comment: "カテゴリID"
      t.string :input_category_name, comment: "カテゴリ名"
      t.integer :operation_log_target_id, comment: "フォームID"
      t.string :form_cd, comment: "フォームCD"
      t.string :form_name, comment: "フォーム名"
      t.string :screen_name, comment: "画面名"
      t.string :operation_div, comment: "操作区分"
      t.text :description, comment: "説明"

      t.datetime :deleted_at, index: true, comment: "削除日時"
      t.timestamps
      t.integer :creator_id, comment: "作成ユーザID"
      t.integer :updater_id, comment: "更新ユーザID"
      t.integer :deleter_id, comment: "削除ユーザID"
    end
  end
end
