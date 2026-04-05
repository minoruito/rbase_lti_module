# -*- coding: utf-8 -*-
module RbaseLtiModule
  module ApplicationHelperExt
    extend ActiveSupport::Concern

    def self.included(mod)
      mod.module_eval do
        def render_aside_with_rbase_lti_module
          render "common/aside_custom"
        end
      end
    end
  end
end
