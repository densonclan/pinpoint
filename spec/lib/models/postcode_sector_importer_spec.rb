require 'spec_helper'

describe PostcodeSectorImporter do
  let(:importer) { PostcodeSectorImporter.new(transport) }

  let(:transport) { FactoryGirl.create :postcode_sector_transport }


  describe 'model_class' do
    specify { importer.model_class.should == PostcodeSector }
  end

  describe 'field_names' do
    specify { importer.class.field_names.should ==    %w(area district sector residential business zone) }
  end


  describe 'postcode_sector update' do
    let!(:postcode_sector) { FactoryGirl.create :postcode_sector, area: 'AB', district: 10, sector: 1, residential: 111, zone: 'D' }

    let(:headers) { %w( area district sector residential business zone ) }
    let(:row)     { %w( AB   10       1      123         836      D    ) }

    before do
      importer.stub(:headers) { headers }
      importer.spreadsheet.stub(:row) { row }
      importer.import!
      postcode_sector.reload
    end

    it { expect(importer).to be_valid }

    it 'should update postcode_sector' do
      expect(postcode_sector.residential).to eq 123
    end

    context 'when residential columns is swapped with business' do
      let(:headers) { %w( area district sector business residential zone ) }
      let(:row)     { %w( AB   10       1      836      123         D    ) }

      it { expect(importer).to be_valid }

      it 'should update postcode_sector' do
        expect(postcode_sector.residential).to eq 123
      end
    end

    context 'when zone column is missed' do
      let(:headers) { %w( area district sector residential business ) }
      let(:row)     { %w( AB   10       1      123         836      ) }

      it { expect(importer).to be_valid }

      it 'should update postcode_sector' do
        expect(postcode_sector.residential).to eq 123
      end

      it 'should not reset zone' do
        expect(postcode_sector.zone).to eq 'D'
      end
    end

    context 'when number has comma' do
      let(:headers) { %w( area  district sector business residential zone ) }
      let(:row)     {   [ 'AB', '10',    '1',   '836',   ' 1,234 ',    'D'  ] }

      it { expect(importer).to be_valid }

      it 'should update postcode_sector' do
        expect(postcode_sector.residential).to eq 1234
      end
    end

    context 'when number has space' do
      let(:headers) { %w( area  district sector business residential zone ) }
      let(:row)     {   [ 'AB', '10',    '1',   '836',   ' 1 234 ',    'D'  ] }

      it { expect(importer).to be_valid }

      it 'should update postcode_sector' do
        expect(postcode_sector.residential).to eq 1234
      end
    end
  end
end
