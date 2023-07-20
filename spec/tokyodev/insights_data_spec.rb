# frozen_string_literal: true

RSpec.describe Tokyodev::InsightsData do
  before(:all) { @data = described_class.data }
  describe '.data' do
    subject(:data) { @data }

    describe 'specific year' do
      subject(:specific_year) { data[:"2022-developer-survey"] }
      it { should_not be_nil }
      describe '.slides' do
        subject(:slides) { specific_year.slides }
        it { should_not be_nil }
        it { expect(slides.keys).to include(:age, :"employer-size") }
      end
      describe '.slide_ordering' do
        subject(:slide_ordering) { specific_year.slide_ordering }
        it { should be_a(Array) }
        it { expect(slide_ordering.first).to be_a(Symbol)}
      end
      describe '.charts' do
        subject(:charts) { specific_year.charts }
        it { should_not be_nil }
        it { expect(charts.keys).to include(:age, :"employer-size") }
        describe '.age' do
          subject(:age) { charts.age }
          it { expect(age.first.label).to eq("Under 20") }
        end
      end
    end


    it { expect( subject["2022-developer-survey"]).to_not be_nil }
  end
end
