require 'spec_helper'

describe 'stores/documents.haml' do

  # before do
  #   assign(:store, a_pretend(:store, id: 12, account_number: 'ABC0987'))
  #   read_only_user
  # end

  # describe 'with no documents' do
  #   before { assign(:documents, paginated_collection_of(:document, 0)) }
  #   describe 'show correct info' do
  #     before { render }
  #     specify { rendered.should include('<h1>\nDocuments for ABC0987')}
  #     specify { rendered.should include('<small>\n(0)') }
  #     specify { rendered.should include('No documents yet.') }
  #   end
  #   describe 'as read only user' do
  #     before { render }
  #     specify { rendered.should_not include(new_document_path(store_id: 12)) }
  #   end

  #   describe 'as client user' do
  #     before do
  #       client_user
  #       render
  #     end
  #     specify { rendered.should include(link_to("Add one!", new_document_path(store_id: 12))) }
  #     specify { rendered.should include(link_to("Add new", new_document_path(store_id: 12))) }
  #   end
  # end

  # describe 'with 3 documents' do
  #   before { assign(:documents, paginated_collection_of(:document, 3)) }

  #   describe 'show correct info' do
  #     before { render }
  #     specify { rendered.should include('<h1>\nDocuments for ABC0987')}
  #     specify { rendered.should include('<small>\n(3)') }
  #   end

  #   describe 'as read only user' do
  #     before { render }
  #     specify { rendered.should_not include(new_document_path(store_id: 12)) }
  #   end

  #   describe 'as client user' do
  #     before do
  #       client_user
  #       render
  #     end
  #     specify { rendered.should include(new_document_path(store_id: 12)) }
  #   end
  # end
end