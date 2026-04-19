module RbaseLtiModule
  module AdminUsers
    module SessionsControllerExt
      def after_sign_in_path_for_with_rbase_lti_module(resource)
        if current_admin_user and session[:current_lms_user].blank?
          lms_user = ::LmsUser.where(admin_user_id: current_admin_user.id).first
          session[:current_lms_user] = lms_user
        end
        after_sign_in_path_for_without_rbase_lti_module(resource)
      end

      def destroy_with_rbase_lti_module
        destroy_without_rbase_lti_module
        session[:current_lms_user] = nil
      end
    end
  end
end