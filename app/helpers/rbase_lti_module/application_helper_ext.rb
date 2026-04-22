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
        # Turbo 等の fetch では Sec-Fetch-Dest が iframe にならず、検索後に閉じるが再表示されるため
        # 一度 embed と判定したらセッションに保持し、最上位の document ナビゲーションでのみ解除する。
        def hide_canvas_admin_top_menu_close_button?
          dest = request.get_header("HTTP_SEC_FETCH_DEST").to_s
          mode = request.get_header("HTTP_SEC_FETCH_MODE").to_s
          if params[:lti_ctx].present? || dest == "iframe"
            session[:canvas_admin_embedded_ui] = true
          elsif dest == "document" && mode == "navigate"
            session.delete(:canvas_admin_embedded_ui)
          end
          session[:canvas_admin_embedded_ui].present?
        end
      end
    end
  end
end
