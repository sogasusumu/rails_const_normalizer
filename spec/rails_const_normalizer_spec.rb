require 'spec_helper'
require 'rails_const_normalizer'
require 'active_support/all'

RSpec.describe RailsConstNormalizer do
  using RailsConstNormalizer

  describe :normalize do
    shared_examples :should_remove do
      it(:should_remove) { expect(actual).to eq expected }
    end

    let(:expected) { 'normalized' }
    let(:method_name) { :normalize }
    let(:actual) { receiver.send(method_name) }

    context :has_double_byte_char do
      let(:receiver) { 'ｎormalized' }
      it_behaves_like :should_remove
    end

    context :has_double_byte_space do
      let(:receiver) { '　　no　　　rm　　al　iz　ed　　　' }
      it_behaves_like :should_remove
    end

    context :has_tab do
      let(:receiver) { "\t\t\tno\trm\tal\tiz\t\ted\t\t" }
      it_behaves_like :should_remove
    end

    context :has_space do
      let(:receiver) { ' no  rm al iz ed  ' }
      it_behaves_like :should_remove
    end

    context :has_enter do
      let(:receiver) { "\nn\nor\n\nm\n\n\nalized\n\n" }
      it_behaves_like :should_remove
    end
  end

  describe :to do
    let(:expected) { 'name' }
    let(:format) { nil }
    let(:actual) { receiver.to(type, format) }

    shared_examples :should_return_expected do
      it { expect(actual).to eq expected }
    end

    shared_examples :format_variations do
      let(:base_name) { 'name' }
      let(:format_method) { :pluralize }
      let(:receiver) { base_name.send(format_method) }
      it_behaves_like :should_return_expected

      context :camelize do
        let(:receiver) { base_name.send(format_method).camelize }
        it_behaves_like :should_return_expected
      end

      context :has_suffix do
        let(:receiver) { [base_name.send(format_method), suffix].reject(&:blank?).join(separator) }
        it_behaves_like :should_return_expected

        context :camelize do
          let(:receiver) { [base_name.send(format_method), suffix].reject(&:blank?).join(separator).camelize }
          it_behaves_like :should_return_expected
        end
      end
    end

    context :controller do
      let(:type) { :controller }
      let(:format) { nil }
      let(:suffix) { type.to_s }
      let(:separator) { '_' }
      let(:expected) { "names_#{suffix}" }
      it_behaves_like :format_variations

      context :with_out_suffix do
        let(:format) { :with_out_suffix }
        let(:expected) { 'names' }
        it_behaves_like :format_variations
      end

      context :file_name do
        let(:format) { :file_name }
        let(:expected) { "names_#{suffix}.rb" }
        it_behaves_like :format_variations
      end

      context :file_path do
        let(:format) { :file_path }
        let(:expected) { "controllers/names_#{suffix}.rb" }
        it_behaves_like :format_variations
      end

      context :klass do
        let(:format) { :klass }
        let(:expected) { "Names#{suffix.camelize}" }
        it_behaves_like :format_variations
      end

      context :klass_name do
        let(:format) { :klass_name }
        let(:expected) { 'Names' }
        it_behaves_like :format_variations
      end
    end

    context :model do
      let(:type) { :model }
      let(:format) { nil }
      let(:suffix) { nil }
      let(:separator) { '_' }
      let(:expected) { "name" }
      it_behaves_like :format_variations

      context :file_name do
        let(:format) { :file_name }
        let(:expected) { "name.rb" }
        it_behaves_like :format_variations
      end

      context :klass do
        let(:format) { :klass }
        let(:expected) { "Name" }
        it_behaves_like :format_variations
      end

      context :table do
        let(:format) { :table }
        let(:expected) { 'names' }
        it_behaves_like :format_variations
      end
    end

    context :resources do
      let(:type) { :resources }
      let(:format) { nil }
      let(:suffix) { 'controller' }
      let(:expected) { "resources :names" }
      let(:separator) { '_' }
      it_behaves_like :format_variations
    end

    context :responder do
      let(:type) { :responder }
      let(:controller) { 'controller_name' }
      let(:action) { 'index' }
      let(:receiver) { "#{controller}##{action}" }

      shared_examples :should_return_expected do
        let(:actual) { receiver.to(:responder, format) }
        it { expect(actual).to eq expected }
      end

      let(:format) { nil }
      let(:expected) { "#{action}_responder" }
      it_behaves_like :should_return_expected

      context :klass do
        let(:format) { :klass }
        let(:expected) { "#{controller.classify.pluralize}::#{action.classify}Responder" }
        it_behaves_like :should_return_expected
      end

      context :file_name do
        let(:format) { :file_name }
        let(:expected) { "#{action}_responder.rb" }
        it_behaves_like :should_return_expected
      end

      context :file_path do
        let(:format) { :file_path }
        let(:expected) { "responders/#{controller.pluralize}/#{action}_responder.rb" }
        it_behaves_like :should_return_expected
      end
    end

    context :model_concern do
      let(:type) { :model_concern }
      let(:controller) { 'controller_name' }
      let(:action) { 'index' }
      let(:model) { 'model_ones' }
      let(:receiver) { "#{controller}##{action}-#{model}" }

      shared_examples :should_return_expected do
        let(:actual) { receiver.to(type, format) }
        it { expect(actual).to eq expected }
      end

      let(:format) { nil }
      let(:expected) { "#{model.singularize}" }
      it_behaves_like :should_return_expected

      context :klass do
        let(:format) { :klass }
        let(:expected) { "#{controller.classify.pluralize}::#{action.classify}::#{model.singularize.classify}" }
        it_behaves_like :should_return_expected
      end

      context :file_name do
        let(:format) { :file_name }
        let(:expected) { "#{model.singularize}.rb" }
        it_behaves_like :should_return_expected
      end

      context :file_path do
        let(:format) { :file_path }
        let(:expected) { "models/concerns/#{controller.pluralize}/#{action}/#{model.singularize}.rb" }
        it_behaves_like :should_return_expected
      end
    end

    context :interactor do
      let(:type) { :interactor }
      let(:controller) { 'controller_name' }
      let(:action) { 'index' }
      let(:receiver) { "#{controller}##{action}" }

      shared_examples :should_return_expected do
        let(:actual) { receiver.to(type, format) }
        it { expect(actual).to eq expected }
      end

      let(:format) { nil }
      let(:expected) { "#{action}_interactor" }
      it_behaves_like :should_return_expected

      context :klass do
        let(:format) { :klass }
        let(:expected) { "#{controller.classify.pluralize}::#{action.classify}Interactor" }
        it_behaves_like :should_return_expected
      end

      context :file_name do
        let(:format) { :file_name }
        let(:expected) { "#{action}_interactor.rb" }
        it_behaves_like :should_return_expected
      end

      context :file_path do
        let(:format) { :file_path }
        let(:expected) { "interactors/#{controller.pluralize}/#{action}_interactor.rb" }
        it_behaves_like :should_return_expected
      end
    end
  end

  describe :actions do
    shared_context :should_raise_invalid_value do
      it { expect { receiver.send(method_name) }.to raise_error(RuntimeError) }
    end

    shared_context :should_return_expected do
      let(:expected) { receiver.normalize }
      it { expect(receiver.send(method_name)).to eq expected }
    end

    describe :permit do
      let(:method_name) { :permit! }
      context :invalid_value do
        let(:receiver) { 'invalid' }
        it_behaves_like :should_raise_invalid_value
      end

      context :valid_value do
        %w(index show create update delete).each do |action|
          let(:receiver) { action }
          it_behaves_like :should_return_expected
        end
      end
    end
  end
end
