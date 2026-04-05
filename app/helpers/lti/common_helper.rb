require 'openssl'
require 'base64'

module Lti
  module CommonHelper
    include ::Rbase::PluginModule::Extendable # 継承を許可する宣言（必須）

    def current_lms_user
      session[:current_lms_user]
    end
    
    def show_information_num(lms_user)
      lti_information_lms_users = ::LTIInformation.joins(:lti_information_lms_users)
                                                  .where("lti_information_lms_users.lms_user_id = ? and (lti_information_lms_users.read IS NULL OR lti_information_lms_users.read = 0)", lms_user.id)
                                                  .where("lti_informations.message_div like '#{session[:launch_mode].to_s.upcase}%'")
                                                  .all
      lti_information_lms_users.size > 0 ?
        "<span class='badge badge-danger'>#{lti_information_lms_users.size}</span>".html_safe : ""
    end

    def add_anchor_to_path(url, anchor)
      "#{url}##{anchor}"
    end

    # def to_crypt(plain_text)
    #   crypt_keyword = ::SystemSetting.get_setting(:crypt_keyword, current_site_id)
    #
    #   return plain_text if crypt_keyword.blank?
    #
    #   engine = OpenSSL::Cipher.new('AES-256-CBC')
    #   engine.encrypt
    #   engine.key = crypt_keyword
    #   iv = engine.random_iv
    #   res = engine.update(plain_text) + engine.final
    #   Base64.encode64(iv + res).gsub(/\n/, '')
    # end

    CIPHER = "aes-256-cbc"

    def to_crypt(plain_text)
      # secure = Rails.application.secrets.encrypt_secure_key
      #
      # return plain_text if secure.blank?
      # crypt = ActiveSupport::MessageEncryptor.new(secure)
      #
      secret = Rails.application.secrets.encrypt_secure_key
      encryptor = ::ActiveSupport::MessageEncryptor.new(secret, cipher: CIPHER)

      encryptor.encrypt_and_sign(plain_text, expires_in: 60.minutes)
    end

    def display_dashboard_menu(site_id = nil)
      site_id = current_site_id || Site.first.id unless site_id
      result = []
      dashboard_menu_list = SystemSetting.get_multivalue_list(:dashboard_display_list, site_id)
      role = current_lms_user.role_entry[:role_name]
      if role != "admin"
        dashboard_menu_list = dashboard_menu_list.select{|x| x[:value_div] == role}
      end
      dashboard_menu_list = dashboard_menu_list.select{|x| x[:value].blank? || x[:value].to_s == session[:launch_mode].to_s}
      dashboard_menu_list.each do |menu|
        menu_title = menu[:value2]
        m = menu_title.match(/\[B:([^\]]+)\]\z/)
        if m.present? and m[1].present?
          badge_string = eval(m[1])
          menu_title = menu_title.sub(/\s*\[B:[A-Za-z0-9_]+\]\s*\z/, "")
          menu_title = (menu_title + badge_string.to_s).html_safe
        end
        result << link_to(menu_title, eval("#{menu[:value4]}_path(type: '#{menu[:value3]}', clear: true)"))
      end
      safe_join(result)
    end
  end
end
