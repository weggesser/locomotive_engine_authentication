module Locomotive
  module Wagon

    class PageDecorator < Locomotive::Steam::Decorators::TemplateDecorator

      include ToHashConcern
      include PersistAssetsConcern

      attr_accessor :__content_assets_pusher__, :__persist_content__

      def initialize(object, locale, content_assets_pusher, persist_content)
        self.__content_assets_pusher__ = content_assets_pusher
        self.__persist_content__ = persist_content
        super(object, locale, nil) # we don't need a fallback to the default locale
      end

      def __attributes__
        _attributes = %i(title slug parent
          handle response_type published
          position listed
          is_layout allow_layout
          redirect_url redirect_type
          seo_title meta_keywords meta_description
          editable_elements
          content_type
          template protected)

        # remove the attributes that end-users might have modified in the back-office
        if persisted? && !__persist_content__
          _attributes -= %i(title published listed position seo_title meta_keywords meta_description editable_elements protected)
        end

        # no need to update the slug if this is for an update
        # in case of a localized site, if this is a new page, the _id will remain empty
        # for the other locales.
        _attributes -= %i(slug) if persisted?

        _attributes
      end

      def _id=(id)
        __getobj__[:remote_id] = id
      end

      def _id
        __getobj__[:remote_id]
      end

      def is_layout
        if self[:is_layout].nil?
          !(__getobj__._fullpath =~ %r(^layouts/)).nil?
        else
          self[:is_layout]
        end
      end

      def allow_layout
        self[:allow_layout]
      end

      def response_type
        self[:response_type]
      end

      def parent
        self[:parent]
      end

      def content_type
        templatized? ? content_type_id : nil
      end

      def editable_elements
        return nil if __getobj__.editable_elements.all.count == 0

        __getobj__.editable_elements.all.map do |element|
          EditableElementDecorator.new(element, __locale__, __content_assets_pusher__)
        end
      end

      def template
        replace_with_content_assets!(self.liquid_source)
      end

      def folder_path
        *segments, slug = fullpath.split('/')
        segments.join('/')
      end

      private

      def persisted?
        self._id.present?
      end

    end

  end
end
