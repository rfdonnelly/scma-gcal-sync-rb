require 'test_helper'

describe 'EventPage' do
  describe 'parse_description' do
    it 'works' do
      input_expected = {
        'fixtures/event1.html' => <<~EOF,
          Climbing at Yosemite NP
          Climbing at Yosemite Valley Camping two nights at Upper Pines Campground -- Sat, Sun nights, sites 11, 113, 212
          Trip Leader:Â Randy Worth
        EOF
        'fixtures/event2.html' => <<~EOF,
          Climbing at Red Rock Canyon National Conservation Area
          Camping 3 Nights (Fri, Sat, Sun) Group SiteÂÂ\"Roadrunner\"Â ( = old site name \"C\")

          Leaders: LeRoy Russ &amp; Fred Batliner
        EOF
        'fixtures/event3.html' => <<~EOF,
          Access Fund / SCMA “Adopt-a-Crag” at Big Rock

          This event is an Access
          Fund / SCMA “Adopt-a-Crag” project. The Access Fund Conservation Team will
          be there on Sunday, March 8th to partner and help us to continue our work
          at Big Rock.


          Signup here on the Trip
          Calendar. We have reserved a group campsite at the Lake Perris for Saturday
          night (3/7) so you can climb Saturday, camp Saturday night, and help out with the
          service project on Sunday. Or just come on out Sunday ready to work.


          Group campsite #1 in the Bernasconi
          Campground.
          Overnight parking pass provided for the first 10 people to sign up.


          Trip
          leader: Steve Sauter
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
