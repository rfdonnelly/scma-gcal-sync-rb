require 'test_helper'

describe 'EventPage' do
  describe 'parse_description' do
    it 'works' do
      input_expected = {
        'fixtures/event1.html' => <<~EOF,
          Climbing at Yosemite NP
          Climbing at Yosemite Valley
          Camping two nights at Upper Pines Campground -- Sat, Sun nights, sites 11, 113, 212
          Trip Leader:Â  Randy Worth
        EOF
        'fixtures/event2.html' => <<~EOF,
          Climbing at Red Rock Canyon National Conservation Area
          Camping 3 Nights (Fri, Sat, Sun)
          Group SiteÂ Â \"Roadrunner\"Â  ( = old site name \"C\")
          Leaders: LeRoy Russ & Fred Batliner
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

  describe 'parse_attendees' do
    it 'works' do
      input_expected = {
        'fixtures/event1.html' => [
          {'attendee'=>"Juan Carlos Marvizon", 'count'=>"1", "comment"=>"Willing to carpool. Available for evals. Looking for partners."},
          {'attendee'=>"Humza Javed", 'count'=>"4", "comment"=>"HI Is there space on this trip for me to bring 3 guests? Thank you"},
          {'attendee'=>"Joe Capoccia", 'count'=>"3", "comment"=>"Looking to bring my family if there are enough spots"},
          {'attendee'=>"Justin Barham", 'count'=>"2", "comment"=>"Saturday night. Hope to stay in my car. Guest will tent."},
          {'attendee'=>"Spencer Mathews", 'count'=>"1", "comment"=>"I may bring a guest, but no more than one vehicle."},
          {'attendee'=>"Sherman Lam", 'count'=>"1", "comment"=>""},
          {'attendee'=>"Rob Donnelly", 'count'=>"4", "comment"=>"1 car 1 tent 1-3 guests (family)"}
        ],
        'fixtures/event2.html' => [
        ],
        'fixtures/event3.html' => [
          {'attendee'=>"LeRoy Russ", 'count'=>"1", "comment"=>""},
          {'attendee'=>"Inge Mueller", 'count'=>"1", "comment"=>"Planning to help at RCSC on Saturday, camp at Big Rock and work with everyone on Sunday."},
          {'attendee'=>"Sarah Barron", 'count'=>"1", "comment"=>"I'll be in Sat. evening, after finishing up with the RCSC #3 at Rubidoux. Hopefully in time for a little sunset climbing. ;-)  How do I enter if the gate is locked? THANKS!"}
        ],
      }

      o = SCMAGCal::Input::Web::EventPage.new
      input_expected.each do |input, expected|
        page = o.local_page(input)
        actual = o.parse_attendees(page)

        actual.must_equal expected
      end
    end
  end

  describe 'parse_comments' do
    it 'works' do
      input_expected = {
        'fixtures/event1.html' => [
        ],
        'fixtures/event2.html' => [
        ],
        'fixtures/event3.html' => [
          {
            "author"=>"Rachel Wing",
            "text"=>"Torn between this on Saturday and RCSC at Rubidoux -- is there any way to camp at Big Rock on Friday night ... and is anybody free to climb Friday afternoon?",
            "time"=>"2020-02-04T17:57:06+00:00"
          }
        ],
      }

      o = SCMAGCal::Input::Web::EventPage.new
      input_expected.each do |input, expected|
        page = o.local_page(input)
        actual = o.parse_comments(page)

        actual.must_equal expected
      end
    end
  end
end
