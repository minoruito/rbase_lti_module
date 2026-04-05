class LmsUserImportRow
  include ::SelectableAttr::Base
  include ActiveModel::Model

  attr_accessor :username
  attr_accessor :name
  attr_accessor :given_name
  attr_accessor :family_name
  attr_accessor :email
  attr_accessor :lms
  attr_accessor :role

  attr_accessor :lti_org_id
  attr_accessor :institution
  attr_accessor :inst_org_id
  attr_accessor :department
  attr_accessor :dept_org_id
  attr_accessor :entering_year

  attr_accessor :attr1
  attr_accessor :attr2
  attr_accessor :attr3
  attr_accessor :attr4
  attr_accessor :attr5
  attr_accessor :attr6
  attr_accessor :attr7
  attr_accessor :attr8
  attr_accessor :attr9
  attr_accessor :attr10

  selectable_attr :edit_div do
    entry 'ADD', :add, '追加'
    entry 'EDIT', :edit, '編集'
    entry 'DEL', :del, '削除'
  end

  validates :edit_div, presence: true
  validates :edit_div, inclusion: {in: ::LmsUserImportRow.edit_div_ids}

  validates :username, presence: true
  validates :name, presence: true
  validates :given_name, presence: true, if: Proc.new{|x| x.given_name != '　'}
  validates :family_name, presence: true, if: Proc.new{|x| x.family_name != '　'}
  validates :email, {presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }}

  validates :lms, presence: true
  validates :role, presence: true

  #  全体の検証
  validate :validate_csv

  def validate_csv
    #登録系区分の確認
    if self.edit_div_key == :add
      if ::LmsUser.where(username: self.username).first
        self.errors.add(:username, I18n.t(:"views.lms_user_imports.messages.already_exists"))
      end

      if ::LmsUser.where(email: self.email).first
        self.errors.add(:username, I18n.t(:"views.lms_user_imports.messages.already_email_exists"))
      end
    #編集または削除なのに存在していない
    elsif [:edit, :del].include?(self.edit_div_key)
      unless ::LmsUser.where(username: self.username).first
        self.errors.add(:username, I18n.t(:"views.lms_user_imports.messages.no_exists_username"))
      end
    end

    #学部／学科の確認
    if self.institution.present? || self.department.present?
      if self.institution.blank?
        self.errors.add(:institution, I18n.t(:"activerecord.errors.messages.blank"))
      elsif self.department.blank?
        self.errors.add(:department, I18n.t(:"activerecord.errors.messages.blank"))
      end
    end
    
    if self.institution.present? and self.department.present?
      #lti_org_idが設定されていない場合、名称が不正
      if self.lti_org_id.nil?
        self.errors.add(:base, I18n.t(:"activerecord.errors.messages.invalid_inst_depart"))
      end
    end

    #issの確認
    if self.lms.present?
      unless ::LTIDatabase.where(iss: self.lms).first
        self.errors.add(:lms, I18n.t(:"activerecord.errors.messages.invalid_attribute"))
      end
    end

    if self.errors.size > 0
      false
    else
      true
    end
  end
end
