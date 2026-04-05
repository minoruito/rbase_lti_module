module Lti
  class AdminBasesController < BasesController
    layout "application_lti_admin"
    prepend_view_path 'custom/app/views'

    before_action :set_login
  end
end