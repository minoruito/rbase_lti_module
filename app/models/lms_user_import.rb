require 'csv'
require 'roo'

class LmsUserImport < ApplicationRecord
  include ApplicationConcern

  before_create :created_userstamp
  before_update :updated_userstamp
  after_destroy :destroyed_userstamp

  include ::SelectableAttr::Base

  has_many :lms_user_import_attachments, class_name: '::LmsUserImportAttachment', dependent: :destroy
  accepts_nested_attributes_for :lms_user_import_attachments

  has_many :lms_user_import_errors, class_name: '::LmsUserImportError', dependent: :destroy

  has_one :import_history, dependent: :destroy

  attr_accessor :uuid
  attr_accessor :filename
  attr_accessor :current_admin_user

  validates :lms_user_import_attachments, presence: true

  def set_unique_key
    self.uuid = SecureRandom.hex
  end

  def self.build_data(condition)
    result = []
    # lms_users = ::LmsUser.all
    lms_users = condition.search

    header = %w(
        編集区分 ユーザID ユーザ名 名 姓 メールアドレス 登録元LMS 権限 学部 学科 入学年度 属性1 属性2 属性3 属性4 属性5 属性6 属性7 属性8 属性9 属性10
    )

    result << header

    lms_users.each do |lms_user|
      institution = lms_user.lti_org.try(:parent_institution).try(:org_name)
      department = lms_user.lti_org.try(:parent_department).try(:org_name)
      role_name = lms_user.role #::Role.where(role_short_name: lms_user.role).first.try(:role_name)
      form_column_value = [
        LmsUserImportRow.edit_div_id_by_key(:edit),       #1:編集区分
        lms_user.username,                                #2:ユーザID
        lms_user.name,                                    #3:ユーザ名
        lms_user.given_name,                              #4:名
        lms_user.family_name,                             #5:姓
        lms_user.email,                                   #6:メールアドレス
        lms_user.lms,                                     #7:登録元LMS
        role_name,                                        #8:権限
        institution,                                      #9:学部
        department,                                       #10:学科
        lms_user.entering_year,                           #11:入学年度
        lms_user.attr1,                                   #12:属性1
        lms_user.attr2,                                   #13:属性2
        lms_user.attr3,                                   #14:属性3
        lms_user.attr4,                                   #15:属性4
        lms_user.attr5,                                   #16:属性5
        lms_user.attr6,                                   #17:属性6
        lms_user.attr7,                                   #18:属性7
        lms_user.attr8,                                   #19:属性8
        lms_user.attr9,                                   #20:属性9
        lms_user.attr10                                   #21:属性10
      ]

      result << form_column_value
    end
    result
  end

  def self.build_csv(data)
    #csv_data = CSV.generate(col_sep: ',', force_quotes: true, quote_char: '"') do |csv|
    bom = %w[EF BB BF].map { |e| e.hex.chr }.join
    csv_data = CSV.generate(bom, col_sep: ',', force_quotes: true, quote_char: '"') do |csv|
      data.each do |d|
        csv << d
      end
    end
    csv_data
  end

  def self.generate_xlsx(data)
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet do |sheet|
        linebreak_style = sheet.styles.add_style(alignment: {wrap_text: true})
        data.each do |row|
          sheet.add_row row, types: Array.new(row.size, :string), style: linebreak_style
        end
        sheet.column_widths(*[20]*data.size)
      end
    end
  end

  def import_csv
    @lms_user_import_rows = []
    header = false
    filepath = self.lms_user_import_attachments[0].document.path
    xlsx = Roo::Excelx.new(filepath)
    xlsx.default_sheet = xlsx.sheets[0]
    2.upto(xlsx.last_row) do |r_num|
      row = xlsx.row(r_num)
      lms_user_import_row = ::LmsUserImportRow.new
      lms_user_import_row.edit_div = row[0]                 #編集区分
      lms_user_import_row.username = row[1].to_s            #ユーザID
      lms_user_import_row.name = row[2]                     #ユーザ名
      lms_user_import_row.given_name = row[3]               #名
      lms_user_import_row.family_name = row[4]              #姓
      lms_user_import_row.email = row[5]                    #メールアドレス
      lms_user_import_row.lms = row[6]                      #登録元LMS

      lms_user_import_row.role = row[7]                     #権限

      lms_user_import_row.institution = row[8]              #学部
      lms_user_import_row.department = row[9]               #学科
      lms_user_import_row.entering_year = row[10]           #入学年度

      #組織IDの設定
      if lms_user_import_row.institution.present? and lms_user_import_row.department.present?
        lti_org = ::LTIOrg.get_lti_org(lms_user_import_row.institution, lms_user_import_row.department)
        unless lti_org.nil?
          lms_user_import_row.lti_org_id = lti_org.id
        end
      end

      lms_user_import_row.attr1 = row[11]                   #属性1
      lms_user_import_row.attr1 = row[12]                   #属性2
      lms_user_import_row.attr1 = row[13]                   #属性3
      lms_user_import_row.attr1 = row[14]                   #属性4
      lms_user_import_row.attr1 = row[15]                   #属性5
      lms_user_import_row.attr1 = row[16]                   #属性6
      lms_user_import_row.attr1 = row[17]                   #属性7
      lms_user_import_row.attr1 = row[18]                   #属性8
      lms_user_import_row.attr1 = row[19]                   #属性9
      lms_user_import_row.attr1 = row[20]                   #属性10

      ::Rails.logger.info("[LMSユーザインポート]load #{lms_user_import_row.edit_div} / #{lms_user_import_row.username}")

      @lms_user_import_rows << lms_user_import_row
    end

    # バリデーション
    @lms_user_import_rows.each_with_index do |lms_user_import_row, index|
      ::Rails.logger.info("[LMSユーザインポート](#{index+1}/#{@lms_user_import_rows.size})valid #{lms_user_import_row.edit_div} / #{lms_user_import_row.username}")
      unless lms_user_import_row.valid?
        lms_user_import_error = ::LmsUserImportError.new({line_no: index+2, error_message: lms_user_import_row.errors.full_messages.join("\n")})

        self.build_lms_user_import_errors if self.lms_user_import_errors.nil?
        self.lms_user_import_errors << lms_user_import_error unless lms_user_import_error.nil?
      end
    end

    if self.lms_user_import_errors.empty?
      if self.save
        save_lms_users
        return true
      else
        self.errors.add(:base, I18n.t(:"activerecord.errors.messages.fail_import"))
      end
      false
    end
  end

  private
  LMS_USER_ATTR = %w(
    username
    name
    given_name
    family_name
    email
    lms
    role
    lti_org_id
    entering_year
    attr1
    attr2
    attr3
    attr4
    attr5
    attr6
    attr7
    attr8
    attr9
    attr10
  )

  def save_lms_users
    ::Rails.logger.info("[LMSユーザインポート]開始")

    #インポート行の内、フォーム処理行から処理を行う
    @lms_user_import_rows.each_with_index do |lms_user_import_row, index|
      case lms_user_import_row.edit_div_key
      when :add then
        ::Rails.logger.info("[LMSユーザインポート](#{index+1}/#{@lms_user_import_rows.size})ADD:#{lms_user_import_row.username}")
        lms_user = ::LmsUser.new
        LMS_USER_ATTR.each do |attr|
          lms_user.send("#{attr}=", lms_user_import_row.send(attr.to_sym))
        end

        #学科設定
        lms_user.dept_org_id = lms_user.lti_org_id

        #学部設定
        lms_user.inst_org_id = lms_user.lti_org.parent_institution.id if lms_user.lti_org

        lti_database = ::LTIDatabase.where(iss: lms_user_import_row.lms).first
        site_ids = lti_database.site_ids
        lms_user.site_ids = site_ids

        lms_user.save!
        admin_user = lms_user.create_admin_user_for_import
        lms_user.admin_user_id = admin_user.id
        lms_user.save!

      when :edit then
        ::Rails.logger.info("[LMSユーザインポート](#{index+1}/#{@lms_user_import_rows.size})EDIT:#{lms_user_import_row.username}")
        lms_user = ::LmsUser.where(username: lms_user_import_row.username).first
        LMS_USER_ATTR.each do |attr|
          lms_user.send("#{attr}=", lms_user_import_row.send(attr.to_sym))
        end

        #学科設定
        lms_user.dept_org_id = lms_user.lti_org_id

        #学部設定
        lms_user.inst_org_id = lms_user.lti_org.parent_institution.id if lms_user.lti_org

        lti_database = ::LTIDatabase.where(iss: lms_user_import_row.lms).first
        site_ids = lti_database.site_ids
        lms_user.site_ids = site_ids

        lms_user.save!
        admin_user = lms_user.create_admin_user_for_import

        if lms_user.admin_user_id.nil?
          lms_user.admin_user_id = admin_user.id
          lms_user.save!
        end
      when :del then
        ::Rails.logger.info("[LMSユーザインポート](#{index+1}/#{@lms_user_import_rows.size})DEL:#{lms_user_import_row.username}")
        lms_user = ::LmsUser.where(username: lms_user_import_row.username).first
        raise "fail destroy #{lms_user.username}" unless lms_user.destroy_lms_user
      end
    end
    ::Rails.logger.info("[LMSユーザインポート]終了")
  end

  ## オフラインでのLMSユーザの一括インポート
  def self.import_lms_users(file_name, site_id)
    site_id = ::Site.first.id if site_id.nil?
    logging_task_log("[オフラインLMSユーザインポート]開始 file_name:#{file_name} site_id:#{site_id}")

    admin_role = Role.where(role_short_name: "admin").first
    admin_user = AdminUser.where(role_id:admin_role.id).first

    ActiveRecord::Base.transaction do
      lms_user_import = LmsUserImport.new

      #ファイルの読込
      filepath = "#{::SystemSetting.get_setting(:offline_import_dir, site_id)}/#{file_name}"
      logging_task_log("[オフラインLMSユーザインポート]filepath:#{filepath}")
      f = File.open(filepath, "r")
      lms_user_import_attachment = LmsUserImportAttachment.new
      lms_user_import_attachment.filename = file_name
      lms_user_import_attachment.save!
      lms_user_import_attachment.reload
      lms_user_import_attachment.document.store!(f)

      lms_user_import.current_admin_user = admin_user

      lms_user_import.save!(validate: false)

      lms_user_import_attachment.lms_user_import_id = lms_user_import.id
      lms_user_import_attachment.save!

      import_history = LTIImportHistory.new
      import_history.target = lms_user_import
      import_history.current_admin_user = admin_user
      import_history.save!

      # ::LTI::ImportHistoryJob.perform_now(@lms_user_import.id)
      result = ::LTI::LmsUserImportJob.perform_later(lms_user_import.id)

      import_history.provider_job_id = result.instance_of?(Integer) ? result : result.provider_job_id
      import_history.save!

      FileUtils.rm_f(filepath)

      #
      # if lms_user_import.import_csv
      #   logging_task_log("[オフラインLMSユーザインポート]正常完了")
      #   FileUtils.rm_f(filepath)
      # else
      #   logging_task_log("[オフラインLMSユーザインポート]エラー終了")
      #   puts("---------------------")
      #   lms_user_import.lms_user_import_errors.each do |error|
      #     logging_task_log("#{error.line_no}行目：#{error.error_message}")
      #   end
      #   puts("---------------------")
      # end
      logging_task_log("[オフラインLMSユーザインポート]終了")
    end
  end
end
