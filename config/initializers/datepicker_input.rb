module SimpleForm
  module Inputs

    class DatePickerInput < Base

      def input
        template.content_tag(:div, input_and_icon_span, 'data-date-format' => date_format, 'data-date' => value, 'class' => 'date datepicker input-append')
      end

      private

      def value
        (object.send(reflection_or_attribute_name) || Date.today).strftime('%d-%m-%Y')
      end

      def date_format
        options[:format] || 'dd-mm-yyyy'
      end

      def input_and_icon_span
        @builder.text_field(attribute_name, input_html_options) + icon_span
      end

      def icon_span
        template.content_tag(:span, template.content_tag(:i, nil, class: 'icon-th'), class: 'add-on')
      end
    end
  end

  class FormBuilder < ActionView::Helpers::FormBuilder
    map_type :date_picker, to: SimpleForm::Inputs::DatePickerInput
  end
end