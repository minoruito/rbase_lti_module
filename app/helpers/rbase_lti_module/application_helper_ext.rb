# -*- coding: utf-8 -*-
module RbaseLtiModule
  module ApplicationHelperExt
    extend ActiveSupport::Concern

    def self.included(mod)
      mod.module_eval do
        def current_lms_user
          session[:current_lms_user]
        end

        def render_aside_with_rbase_lti_module
          render "common/aside_custom"
        end

        # Canvas 管理メニューの「閉じる」は iframe 内では不要（window.close が効かない・誤操作防止）
        def hide_canvas_admin_top_menu_close_button?
          params[:lti_ctx].present? ||
            request.get_header("HTTP_SEC_FETCH_DEST").to_s == "iframe"
        end
      end
    end
  end
end
