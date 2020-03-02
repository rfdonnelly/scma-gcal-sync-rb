require 'test_helper'

describe 'EventPage' do
  describe 'parse_description' do
    it 'works' do
      input_expected = {
        'fixtures/event1.html' => <<~EOF,
          Camping two nights at Upper Pines Campground -- Sat, Sun nights, sites 11, 113, 212
          Trip Leader:Â  Randy Worth
        EOF
        'fixtures/event2.html' => <<~EOF,
          Group SiteÂ Â \"Roadrunner\"Â  ( = old site name \"C\")
          Leaders: LeRoy Russ & Fred Batliner
        EOF
      }

      o = SCMAGCal::Input::Web::EventPage.new
      input_expected.each do |input, expected|
        page = o.local_page(input)
        actual = o.parse_description(page)

        actual.must_equal expected.strip
      end
    end
  end
end
