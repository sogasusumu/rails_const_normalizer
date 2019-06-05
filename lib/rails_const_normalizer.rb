# frozen_string_literal: true

require 'rails_const_normalizer/version'
require 'active_support/all'

module RailsConstNormalizer
  refine String do
    # @return [String]
    # @raise RuntimeError if receiver not in ``%w(index show create update delete)``
    def permit!
      allowed_actions.delete(self).tap { |s| raise("#{self} is not allow action.") if s.nil? }
    end

    # @return [Array<String>]
    def allowed_actions
      %w[index show create update delete]
    end

    # @return [String]
    def to(type, format = nil)
      send(:normalize).yield_self { |str| format ? str.send(type, format) : str.send(type) }
    end

    # @return [String]
    def normalize
      tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z').gsub(/　/, ' ').gsub(/\s/, '')
    end

    def responder(format = nil)
      "#{split('#').first.controller(:with_out_suffix)}/#{split('#').last.permit!}_responder"
        .yield_self { |str| format ? str.send(format) : str.split('/').last }
    end

    # @return [String]
    def controller(format = nil)
      [underscore.with_out_suffix.pluralize, 'controller'].join('_')
                                                          .yield_self { |str| format ? str.send(format) : str }
    end

    # @return [String]
    def model(format = nil)
      singularize.underscore
                 .yield_self { |str| format ? str.send(format) : str }
    end

    # @return [String]
    def resources
      "resources :#{underscore.with_out_suffix.pluralize}"
    end

    # @return [String]
    def with_out_suffix
      gsub(/_controller/, '')
    end

    # @return [String]
    def file_name
      [split('/').last, 'rb'].join('.')
    end

    # @return [String]
    def file_path
      [
        file_path_prefix,
        [self, 'rb'].join('.')
      ].join('/')
    end

    # @return [String]
    def file_path_prefix
      return 'controllers' if match?(/_controller$/)
      return 'responders' if match?(/_responder$/)

      'models'
    end

    # @return [String]
    def klass
      camelize
    end

    # @return [String]
    def klass_name
      with_out_suffix.camelize
    end

    # @return [String]
    def table
      tableize
    end
  end
end
