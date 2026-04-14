# -*- coding: utf-8 -*-
module RbaseLtiModule
  module CustomFieldExt
    extend ActiveSupport::Concern
    include ::ActiveModel::Validations

    def self.included(mod)
      mod.extend(ClassMethods)
      mod.module_eval do
        scope :lms_users, -> { where(custom_field_type: 'lms_user').order(:display_order) }
      end
    end

    module ClassMethods
    end
  end
end